require 'kaiser/command_runner'

module Kaiser
  # The commandline
  class KaiserCli
    attr_reader :config_dir

    def initialize(work_dir, debug_output:, info_output:)
      @work_dir = work_dir
      @config_dir = "#{ENV['HOME']}/.kaiser"
      FileUtils.mkdir_p @config_dir
      @config_file = "#{@config_dir}/.config.yml"
      @kaiserfile = Kaiserfile.new("#{@work_dir}/Kaiserfile")
      @config = {
        envnames: {},
        envs: {},
        networkname: 'kaiser_net',
        shared_names: {
          redis: 'kaiser-redis',
          nginx: 'kaiser-nginx',
          chrome: 'kaiser-chrome',
          certs: 'kaiser-certs'
        },
        largest_port: 9000
      }
      @out = debug_output
      @info_out = info_output
      load_config
    end

    def init
      return Optimist.die "Already initialized as #{envname}" if envname

      name = ARGV.shift
      return Optimist.die 'Needs environment name' if name.nil?

      init_config_for_env(name)
      save_config
    end

    def deinit
      down
      @config[:envs].delete(envname)
      @config[:envnames].delete(@work_dir)
      save_config
    end

    def up
      ensure_setup
      setup_app
      setup_db
      start_app
    end

    def down
      stop_db
      stop_app
      delete_db_volume
    end

    def shutdown
      @config[:shared_names].each do |_, container_name|
        killrm container_name
      end
      CommandRunner.run @out, "docker network rm #{@config[:networkname]}"
      CommandRunner.run @out, "docker volume rm #{@config[:shared_names][:certs]}"
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
        -p #{app_port}:#{app_expose}
        -e DEV_APPLICATION_HOST=#{app_container_name}
        -e VIRTUAL_HOST=#{app_container_name}
        -e VIRTUAL_PORT=#{app_expose}
        #{volumes}
        #{app_params}
        kaiser:#{envname}-#{current_branch} #{cmd}".tr("\n", ' ')

      @out.puts 'Cleaning up...'
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
        @info_out.puts "app: #{app_port}"
        @info_out.puts "db: #{db_port}"
      elsif cmd == 'cert-source'
        unless @config[:cert_source]
          Optimist.die 'No certificate source set.
            see kaiser set help'
        end

        source = @config[:cert_source][:url] || @config[:cert_source][:folder]
        @info_out.puts source
      elsif cmd == 'http-suffix'
        @info_out.puts http_suffix
      end
    end

    def set
      cmd = ARGV.shift
      if cmd == 'cert-url'
        @config[:cert_source] = {
          url: ARGV.shift
        }
      elsif cmd == 'cert-folder'
        @config[:cert_source] = {
          folder: ARGV.shift
        }
      elsif cmd == 'http-suffix'
        @config[:http_suffix] = ARGV.shift
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

    def largest_port
      @config[:largest_port]
    end

    def ensure_db_volume
      create_if_volume_not_exist db_volume_name
    end

    def setup_db
      ensure_db_volume
      start_db
      return if File.exist?(default_db_image)

      @info_out.puts 'Provisioning database'
      killrm "#{envname}-apptemp"
      status = CommandRunner.run @out, "docker run -ti
        --rm
        --name #{envname}-apptemp
        --network #{@config[:networkname]}
        #{app_params}
        kaiser:#{envname}-#{current_branch} #{db_reset_command}"

      if status != 0
        @info_out.puts "#{envname} db provision failed"
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
      CommandRunner.run @out, "docker volume rm #{db_volume_name}"
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
      @info_out.puts 'Saving database state'
      File.write(to_file, '')
      CommandRunner.run @out, "docker run --rm
        -v #{container}:#{db_data_directory}
        -v #{to_file}:#{to_file}
        ruby:alpine
        tar cvjf #{to_file} #{db_data_directory}"
    end

    def load_db_state_from(file:, to_container:)
      @info_out.puts 'Loading database state'
      CommandRunner.run @out, "docker run --rm
        -v #{to_container}:#{db_data_directory}
        -v #{file}:#{file}
        ruby:alpine
        tar xvjf #{file} -C #{db_data_directory}
          --strip #{db_data_directory.scan(%r{\/}).count}"
    end

    def stop_db
      @info_out.puts 'Stopping database'
      killrm db_container_name
    end

    def start_db
      @info_out.puts 'Starting up database'
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
      CommandRunner.run @out, "docker volume rm #{db_volume_name}"
    end

    def setup_app
      @info_out.puts 'Setting up application'
      File.write(tmp_dockerfile_name, docker_file_contents)
      build_args = docker_build_args.map { |k, v| "--build-arg #{k}=#{v}" }
      CommandRunner.run @out, "docker build
        -t kaiser:#{envname}-#{current_branch}
        -f #{tmp_dockerfile_name} #{@work_dir}
        #{build_args.join(' ')}"
      FileUtils.rm(tmp_dockerfile_name)
    end

    def current_branch_db_image_dir
      "#{config_dir}/databases/#{envname}/#{current_branch}"
    end

    def db_image_path(name)
      if name.start_with?('./')
        path = "#{`pwd`.chomp}/#{name.sub('./', '')}"
        @info_out.puts "Database image path is: #{path}"
        return path
      end
      FileUtils.mkdir_p current_branch_db_image_dir
      "#{current_branch_db_image_dir}/#{name}.tar.bz"
    end

    def default_db_image
      db_image_path('.default')
    end

    def start_app
      @info_out.puts 'Starting up application'
      killrm app_container_name
      CommandRunner.run @out, "docker run -d
        --name #{app_container_name}
        --network #{network_name}
        -p #{app_port}:#{app_expose}
        -e DEV_APPLICATION_HOST=#{app_container_name}
        -e VIRTUAL_HOST=#{app_container_name}
        -e VIRTUAL_PORT=#{app_expose}
        #{app_params}
        kaiser:#{envname}-#{current_branch}"
      wait_for_app
    end

    def stop_app
      @info_out.puts 'Stopping application'
      killrm app_container_name
    end

    def tmp_waitscript_name
      "#{config_dir}/.#{envname}-dbwaitscript"
    end

    def tmp_dockerfile_name
      "#{config_dir}/.#{envname}-dockerfile"
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

      CommandRunner.run @out, "docker create
        -v #{tmp_file_volume}:/tmpvol
        --name #{tmp_file_container} alpine"

      File.write(tmp_waitscript_name, script)

      CommandRunner.run @out, "docker cp
        #{tmp_waitscript_name}
        #{tmp_file_container}:/tmpvol/wait.sh"

      CommandRunner.run @out, "docker run --rm -ti
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

      @info_out.puts 'Waiting for server to start...'
      run_blocking_script('alpine', '', <<-SCRIPT)
        apk update
        apk add curl
        until $(curl --output /dev/null --silent --head --fail http://#{app_container_name}:#{app_expose}); do
            echo 'o'
            sleep 1
        done
      SCRIPT
      @info_out.puts 'Started.'
    end

    def wait_for_db
      @info_out.puts 'Waiting for database to start...'
      run_blocking_script(db_image, db_waitscript_params, db_waitscript)
      @info_out.puts 'Started.'
    end

    def network_name
      @config[:networkname]
    end

    def db_port
      @config[:envs][envname][:db_port]
    end

    def db_expose
      @kaiserfile.database[:port]
    end

    def db_params
      eval_template @kaiserfile.database[:params]
    end

    def db_image
      @kaiserfile.database[:image]
    end

    def db_commands
      eval_template @kaiserfile.database[:commands]
    end

    def db_data_directory
      @kaiserfile.database[:data_dir]
    end

    def server_type
      @kaiserfile.server_type
    end

    def db_waitscript
      eval_template @kaiserfile.database[:waitscript]
    end

    def db_waitscript_params
      eval_template @kaiserfile.database[:waitscript_params]
    end

    def docker_file_contents
      eval_template @kaiserfile.docker_file_contents
    end

    def docker_build_args
      @kaiserfile.docker_build_args
    end

    def app_params
      eval_template @kaiserfile.params
    end

    def db_reset_command
      eval_template @kaiserfile.database_reset_command
    end

    def attach_mounts
      @kaiserfile.attach_mounts
    end

    def eval_template(value)
      ERB.new(value).result(binding)
    end

    def app_port
      @config[:envs][envname][:app_port]
    end

    def app_expose
      @kaiserfile.port
    end

    def db_volume_name
      "#{envname}-database"
    end

    def app_container_name
      "#{envname}.#{http_suffix}"
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
      @config[:http_suffix] || 'lvh.me'
    end

    def copy_keyfile(file)
      if @config[:cert_source][:folder]
        CommandRunner.run @out, "docker run --rm
          -v #{@config[:shared_names][:certs]}:/certs
          -v #{@config[:cert_source][:folder]}:/cert_source
          alpine cp /cert_source/#{file} /certs/#{file}"

      elsif @config[:cert_source][:url]
        CommandRunner.run @out, "docker run --rm
          -v #{@config[:shared_names][:certs]}:/certs
          alpine wget #{@config[:cert_source][:url]}/#{file}
            -O /certs/#{file}"
      end
    end

    def prepare_cert_volume!
      create_if_volume_not_exist @config[:shared_names][:certs]
      return unless @config[:cert_source]

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

      create_if_network_not_exist @config[:networkname]
      if_container_dead @config[:shared_names][:nginx] do
        prepare_cert_volume!
      end
      run_if_dead(
        @config[:shared_names][:redis],
        "docker run -d
          --name #{@config[:shared_names][:redis]}
          --network #{@config[:networkname]}
          redis:alpine"
      )
      run_if_dead(
        @config[:shared_names][:chrome],
        "docker run -d
          -p 5900:5900
          --name #{@config[:shared_names][:chrome]}
          --network #{@config[:networkname]}
          selenium/standalone-chrome-debug"
      )
      run_if_dead(
        @config[:shared_names][:nginx],
        "docker run -d
          -p 80:80
          -p 443:443
          -v #{@config[:shared_names][:certs]}:/etc/nginx/certs
          -v /var/run/docker.sock:/tmp/docker.sock:ro
          --name #{@config[:shared_names][:nginx]}
          --network #{@config[:networkname]}
          jwilder/nginx-proxy"
      )
    end

    def network
      `docker network inspect #{@config[:networkname]} 2>/dev/null`
    end

    def if_container_dead(container, &block)
      x = JSON.parse(`docker inspect #{container} 2>/dev/null`)
      return unless x.length.zero? || x[0]['State']['Running'] == false

      yield if block
    end

    def create_if_volume_not_exist(vol)
      x = JSON.parse(`docker volume inspect #{vol} 2>/dev/null`)
      return unless x.length.zero?

      CommandRunner.run @out, "docker volume create #{vol}"
    end

    def create_if_network_not_exist(net)
      x = JSON.parse(`docker inspect #{net} 2>/dev/null`)
      return unless x.length.zero?

      CommandRunner.run @out, "docker network create #{net}"
    end

    def run_if_dead(container, command)
      if_container_dead container do
        @info_out.puts "Starting up #{container}"
        killrm container
        CommandRunner.run @out, command
      end
    end

    def envname
      @config[:envnames][@work_dir]
    end

    def init_config_for_env(name)
      @config[:envnames][@work_dir] = name
      @config[:envs][name] = {
        app_port: (largest_port + 1).to_s,
        db_port: (largest_port + 2).to_s
      }
      @config[:largest_port] = @config[:largest_port] + 2
    end

    def save_config
      File.write(@config_file, @config.to_yaml)
    end

    def load_config
      @config = YAML.load_file(@config_file) if File.exist?(@config_file)
    end

    def killrm(container)
      x = JSON.parse(`docker inspect #{container} 2>/dev/null`)
      return if x.length.zero?

      if x[0]['State'] && x[0]['State']['Running'] == true
        CommandRunner.run @out, "docker kill #{container}"
      end
      CommandRunner.run @out, "docker rm #{container}" if x[0]['State']
    end
  end
end
