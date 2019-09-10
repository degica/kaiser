require 'kaiser/command_runner'

module Kaiser

  # The commandline
  class Cli
    @@subcommands = {}

    def initialize
      # This is here for backwards compatibility since it can be used in Kaiserfiles.
      # It would be a good idea to deprecate this and make it more abstract.
      @work_dir = Config.work_dir
      @config_dir = Config.work_dir
      @config_file = Config.config_file
      @kaiserfile = Config.kaiserfile
      @config = Config.config
      @out = Config.out
      @info_out = Config.info_out
    end

    # At first I did this in the constructor but the problem with that is Optimist
    # will parse the entire commandline for the first Cli command registered.
    # That means no matter what you call -h on, it will always return the help
    # for the first subcommand. Fixed this by only running define_options when
    # a command is run. We can't just run the constructor at that point because
    # we need each Cli class to be constructed in the beginning so we can add their
    # usage text to the output of `kaiser -h`.
    def define_options
      # We can't just call usage within the options block because that actually shifts
      # the scope to Optimist::Parser. We can still reference variables but we can't
      # call instance methods of a Kaiser::Cli class.
      u = usage
      Optimist::options {
        banner u
      }
    end

    def self.register(name, klass)
      @subcommands ||= {}
      @subcommands[name] = klass.new
    end

    def self.run_command(name)
      cmd = @subcommands[name]
      cmd.define_options
      cmd.execute
    end

    def shutdown
      Config.config[:shared_names].each do |_, container_name|
        killrm container_name
      end
      CommandRunner.run Config.out, "docker network rm #{Config.config[:networkname]}"
      CommandRunner.run Config.out, "docker volume rm #{Config.config[:shared_names][:certs]}"
    end

    def db_load
      ensure_setup
      name = ARGV.shift || '.default'
      load_db(name)
    end

    def db_save
      ensure_setup
      name = ARGV.shift || '.default'
      save_db(name)
    end

    def db_reset_hard
      ensure_setup
      if File.exist?(db_image_path('.default'))
        FileUtils.rm db_image_path('.default')
      end
      setup_db
    end

    def db_reset
      ensure_setup
      load_db('.default')
    end

    def attach
      ensure_setup
      cmd = (ARGV || []).join(' ')
      killrm app_container_name

      volumes = attach_mounts.map { |from, to| "-v #{`pwd`.chomp}/#{from}:#{to}" }.join(' ')

      system "docker run -ti
        --name #{app_container_name}
        --network #{network_name}
        --dns #{ip_of_container(Config.config[:shared_names][:dns])}
        --dns-search #{http_suffix}
        -p #{app_port}:#{app_expose}
        -e DEV_APPLICATION_HOST=#{envname}.#{http_suffix}
        -e VIRTUAL_HOST=#{envname}.#{http_suffix}
        -e VIRTUAL_PORT=#{app_expose}
        #{volumes}
        #{app_params}
        kaiser:#{envname}-#{current_branch} #{cmd}".tr("\n", ' ')

      Config.out.puts 'Cleaning up...'
      start_app
    end

    def logs
      exec "docker logs -f #{app_container_name}"
    end

    def login
      ensure_setup
      cmd = (ARGV || []).join(' ')
      exec "docker exec -ti #{app_container_name} #{cmd}"
    end

    def show
      ensure_setup
      cmd = ARGV.shift
      valid_cmds = 'ports cert-source http-suffix'
      return Optimist.die "Available things to show: #{valid_cmds}" unless cmd

      if cmd == 'ports'
        Config.info_out.puts "app: #{app_port}"
        Config.info_out.puts "db: #{db_port}"
      elsif cmd == 'cert-source'
        unless Config.config[:cert_source]
          Optimist.die 'No certificate source set.
            see kaiser set help'
        end

        source = Config.config[:cert_source][:url] || Config.config[:cert_source][:folder]
        Config.info_out.puts source
      elsif cmd == 'http-suffix'
        Config.info_out.puts http_suffix
      end
    end

    def set
      cmd = ARGV.shift
      if cmd == 'cert-url'
        Config.config[:cert_source] = {
          url: ARGV.shift
        }
      elsif cmd == 'cert-folder'
        Config.config[:cert_source] = {
          folder: ARGV.shift
        }
      elsif cmd == 'http-suffix'
        Config.config[:http_suffix] = ARGV.shift
      elsif cmd == 'help-https'
        Optimist.die <<-SET_HELP
          Notes on HTTPS:

          You need to set suffix and either cert-url or cert-folder to enable HTTPS.

          cert-url and cert-folder are mutually exclusive. If you set one of them the other will be erased.

          The cert-url and cert-folder must satisfy the following requirements to work:

          The strings must be the root of certificates named after the suffix. For example,

            if cert-url is https://mydomain.com/certs and your suffix is local.mydomain.com, the following
            url need to be the certificate files:

            https://mydomain.com/certs/local.mydomain.com.chain.pem
            https://mydomain.com/certs/local.mydomain.com.crt
            https://mydomain.com/certs/local.mydomain.com.key

          Another example:

            If you use suffix of localme.com and cert-folder is /home/me/https, The following files need to exist:

            /home/me/https/localme.com.chain.pem
            /home/me/https/localme.com.crt
            /home/me/https/localme.com.key

        SET_HELP
      else
        Optimist.die <<-SET_HELP
          kaiser set <subcommand>

          This command lets you set up special variables that configure kaiser's behavior for you.

          Available subcommands:

          http-suffix - Sets the domain suffix for the reverse proxy to use (defaults to lvh.me)
          cert-url    - Sets up a URL from which HTTPS certificates can be downloaded.
          cert-folder - Sets up a folder from which HTTPS certificates can be copied.
          help        - Shows this help message.
          help-https  - Shows the HTTPS notes.

        SET_HELP
      end
      save_config
    end

    private

    def ensure_db_volume
      create_if_volume_not_exist db_volume_name
    end

    def setup_db
      ensure_db_volume
      start_db
      return if File.exist?(default_db_image)

      # Some databases keep state around, best to clean it.
      stop_db
      delete_db_volume
      start_db

      Config.info_out.puts 'Provisioning database'
      killrm "#{envname}-apptemp"
      status = CommandRunner.run Config.out, "docker run -ti
        --rm
        --name #{envname}-apptemp
        --network #{Config.config[:networkname]}
        #{app_params}
        kaiser:#{envname}-#{current_branch} #{db_reset_command}"

      if status != 0
        Config.info_out.puts "#{envname} db provision failed"
        exit!
      end
      save_db('.default')
    end

    def save_db(name)
      killrm db_container_name
      save_db_state_from container: db_volume_name, to_file: db_image_path(name)
      start_db
    end

    def load_db(name)
      check_db_image_exists(name)
      killrm db_container_name
      CommandRunner.run Config.out, "docker volume rm #{db_volume_name}"
      delete_db_volume
      create_if_volume_not_exist db_volume_name
      load_db_state_from file: db_image_path(name), to_container: db_volume_name
      start_db
    end

    def check_db_image_exists(name)
      return if File.exist?(db_image_path(name))

      Optimist.die 'No saved state exists with that name'
    end

    def save_db_state_from(container:, to_file:)
      Config.info_out.puts 'Saving database state'
      File.write(to_file, '')
      CommandRunner.run Config.out, "docker run --rm
        -v #{container}:#{db_data_directory}
        -v #{to_file}:#{to_file}
        ruby:alpine
        tar cvjf #{to_file} #{db_data_directory}"
    end

    def load_db_state_from(file:, to_container:)
      Config.info_out.puts 'Loading database state'
      CommandRunner.run Config.out, "docker run --rm
        -v #{to_container}:#{db_data_directory}
        -v #{file}:#{file}
        ruby:alpine
        tar xvjf #{file} -C #{db_data_directory}
          --strip #{db_data_directory.scan(%r{\/}).count}"
    end

    def stop_db
      Config.info_out.puts 'Stopping database'
      killrm db_container_name
    end

    def start_db
      Config.info_out.puts 'Starting up database'
      run_if_dead db_container_name, "docker run -d
        -p #{db_port}:#{db_expose}
        -v #{db_volume_name}:#{db_data_directory}
        --name #{db_container_name}
        --network #{network_name}
        #{db_params}
        #{db_image}
        #{db_commands}"
      wait_for_db unless db_waitscript.nil?
    end

    def delete_db_volume
      CommandRunner.run Config.out, "docker volume rm #{db_volume_name}"
    end

    def current_branch_db_image_dir
      "#{Config.config_dir}/databases/#{envname}/#{current_branch}"
    end

    def db_image_path(name)
      if name.start_with?('./')
        path = "#{`pwd`.chomp}/#{name.sub('./', '')}"
        Config.info_out.puts "Database image path is: #{path}"
        return path
      end
      FileUtils.mkdir_p current_branch_db_image_dir
      "#{current_branch_db_image_dir}/#{name}.tar.bz"
    end

    def default_db_image
      db_image_path('.default')
    end

    def start_app
      Config.info_out.puts 'Starting up application'
      killrm app_container_name
      CommandRunner.run Config.out, "docker run -d
        --name #{app_container_name}
        --network #{network_name}
        --dns #{ip_of_container(Config.config[:shared_names][:dns])}
        --dns-search #{http_suffix}
        -p #{app_port}:#{app_expose}
        -e DEV_APPLICATION_HOST=#{envname}.#{http_suffix}
        -e VIRTUAL_HOST=#{envname}.#{http_suffix}
        -e VIRTUAL_PORT=#{app_expose}
        #{app_params}
        kaiser:#{envname}-#{current_branch}"
      wait_for_app
    end

    def tmp_waitscript_name
      "#{Config.config_dir}/.#{envname}-dbwaitscript"
    end

    def tmp_dockerfile_name
      "#{Config.config_dir}/.#{envname}-dockerfile"
    end

    def tmp_db_waiter
      "#{envname}-dbwait"
    end

    def tmp_file_container
      "#{envname}-tmpfiles"
    end

    def tmp_file_volume
      "#{envname}-tmpfiles-vol"
    end

    def run_blocking_script(image, params, script)
      killrm tmp_db_waiter

      killrm tmp_file_container
      create_if_volume_not_exist tmp_file_volume

      CommandRunner.run Config.out, "docker create
        -v #{tmp_file_volume}:/tmpvol
        --name #{tmp_file_container} alpine"

      File.write(tmp_waitscript_name, script)

      CommandRunner.run Config.out, "docker cp
        #{tmp_waitscript_name}
        #{tmp_file_container}:/tmpvol/wait.sh"

      CommandRunner.run Config.out, "docker run --rm -ti
        --name #{tmp_db_waiter}
        --network #{network_name}
        -v #{tmp_file_volume}:/tmpvol
        #{params}
        #{image} sh /tmpvol/wait.sh"

      killrm tmp_file_container

      FileUtils.rm(tmp_waitscript_name)
    end

    def wait_for_app
      return unless server_type == :http

      Config.info_out.puts 'Waiting for server to start...'
      run_blocking_script('alpine', '', <<-SCRIPT)
        apk update
        apk add curl
        until $(curl --output /dev/null --silent --head --fail http://#{app_container_name}:#{app_expose}); do
            echo 'o'
            sleep 1
        done
      SCRIPT
      Config.info_out.puts 'Started.'
    end

    def wait_for_db
      Config.info_out.puts 'Waiting for database to start...'
      run_blocking_script(db_image, db_waitscript_params, db_waitscript)
      Config.info_out.puts 'Started.'
    end

    def network_name
      Config.config[:networkname]
    end

    def db_port
      Config.config[:envs][envname][:db_port]
    end

    def db_expose
      Config.kaiserfile.database[:port]
    end

    def db_params
      eval_template Config.kaiserfile.database[:params]
    end

    def db_image
      Config.kaiserfile.database[:image]
    end

    def db_commands
      eval_template Config.kaiserfile.database[:commands]
    end

    def db_data_directory
      Config.kaiserfile.database[:data_dir]
    end

    def server_type
      Config.kaiserfile.server_type
    end

    def db_waitscript
      eval_template Config.kaiserfile.database[:waitscript]
    end

    def db_waitscript_params
      eval_template Config.kaiserfile.database[:waitscript_params]
    end

    def docker_file_contents
      eval_template Config.kaiserfile.docker_file_contents
    end

    def docker_build_args
      Config.kaiserfile.docker_build_args
    end

    def app_params
      p Config.kaiserfile.params
      eval_template Config.kaiserfile.params
    end

    def db_reset_command
      eval_template Config.kaiserfile.database_reset_command
    end

    def attach_mounts
      Config.kaiserfile.attach_mounts
    end

    def eval_template(value)
      ERB.new(value).result(binding)
    end

    def app_port
      Config.config[:envs][envname][:app_port]
    end

    def app_expose
      Config.kaiserfile.port
    end

    def db_volume_name
      "#{envname}-database"
    end

    def app_container_name
      "#{envname}-app"
    end

    def db_container_name
      "#{envname}-db"
    end

    def current_branch
      `git branch | grep \\* | cut -d ' ' -f2`.chomp.gsub(/[^\-_0-9a-z]+/, '-')
    end

    def ensure_env
      return unless envname.nil?

      Optimist.die('No environment? Please use kaiser init <name>')
    end

    def http_suffix
      Config.config[:http_suffix] || 'lvh.me'
    end

    def copy_keyfile(file)
      if Config.config[:cert_source][:folder]
        CommandRunner.run Config.out, "docker run --rm
          -v #{Config.config[:shared_names][:certs]}:/certs
          -v #{Config.config[:cert_source][:folder]}:/cert_source
          alpine cp /cert_source/#{file} /certs/#{file}"

      elsif Config.config[:cert_source][:url]
        CommandRunner.run Config.out, "docker run --rm
          -v #{Config.config[:shared_names][:certs]}:/certs
          alpine wget #{Config.config[:cert_source][:url]}/#{file}
            -O /certs/#{file}"
      end
    end

    def prepare_cert_volume!
      create_if_volume_not_exist Config.config[:shared_names][:certs]
      return unless Config.config[:cert_source]

      %w[
        chain.pem
        crt
        key
      ].each do |file_ext|
        copy_keyfile("#{http_suffix}.#{file_ext}")
      end
    end

    def ensure_setup
      ensure_env

      setup if network.nil?

      create_if_network_not_exist Config.config[:networkname]
      if_container_dead Config.config[:shared_names][:nginx] do
        prepare_cert_volume!
      end
      run_if_dead(
        Config.config[:shared_names][:redis],
        "docker run -d
          --name #{Config.config[:shared_names][:redis]}
          --network #{Config.config[:networkname]}
          redis:alpine"
      )
      run_if_dead(
        Config.config[:shared_names][:chrome],
        "docker run -d
          -p 5900:5900
          --name #{Config.config[:shared_names][:chrome]}
          --network #{Config.config[:networkname]}
          selenium/standalone-chrome-debug"
      )
      run_if_dead(
        Config.config[:shared_names][:nginx],
        "docker run -d
          -p 80:80
          -p 443:443
          -v #{Config.config[:shared_names][:certs]}:/etc/nginx/certs
          -v /var/run/docker.sock:/tmp/docker.sock:ro
          --privileged
          --name #{Config.config[:shared_names][:nginx]}
          --network #{Config.config[:networkname]}
          jwilder/nginx-proxy"
      )
      run_if_dead(
        Config.config[:shared_names][:dns],
        "docker run -d
          --name #{Config.config[:shared_names][:dns]}
          --network #{Config.config[:networkname]}
          --privileged
          -v /var/run/docker.sock:/docker.sock:ro
          davidsiaw/docker-dns
          --domain #{http_suffix}
          --record :#{ip_of_container(Config.config[:shared_names][:nginx])}"
      )
    end

    def ip_of_container(containername)
      networkname = ".NetworkSettings.Networks.#{Config.config[:networkname]}.IPAddress"
      `docker inspect -f '{{#{networkname}}}' #{containername}`.chomp
    end

    def network
      `docker network inspect #{Config.config[:networkname]} 2>/dev/null`
    end

    def if_container_dead(container, &block)
      x = JSON.parse(`docker inspect #{container} 2>/dev/null`)
      return unless x.length.zero? || x[0]['State']['Running'] == false

      yield if block
    end

    def create_if_volume_not_exist(vol)
      x = JSON.parse(`docker volume inspect #{vol} 2>/dev/null`)
      return unless x.length.zero?

      CommandRunner.run Config.out, "docker volume create #{vol}"
    end

    def create_if_network_not_exist(net)
      x = JSON.parse(`docker inspect #{net} 2>/dev/null`)
      return unless x.length.zero?

      CommandRunner.run Config.out, "docker network create #{net}"
    end

    def run_if_dead(container, command)
      if_container_dead container do
        Config.info_out.puts "Starting up #{container}"
        killrm container
        CommandRunner.run Config.out, command
      end
    end

    def envname
      Config.config[:envnames][Config.work_dir]
    end

    def save_config
      File.write(Config.config_file, Config.config.to_yaml)
    end


    def killrm(container)
      x = JSON.parse(`docker inspect #{container} 2>/dev/null`)
      return if x.length.zero?

      if x[0]['State'] && x[0]['State']['Running'] == true
        CommandRunner.run Config.out, "docker kill #{container}"
      end
      CommandRunner.run Config.out, "docker rm #{container}" if x[0]['State']
    end
  end
end
