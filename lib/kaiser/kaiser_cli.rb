module Kaiser
  # The commandline
  class KaiserCli
    def initialize(work_dir)
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
      @out = $stderr
      load_config
    end

    def init
      return Optimist.die "Already initialized as #{envname}" if envname
      name = ARGV.shift
      return Optimist.die 'Needs environment name' if name.nil?

      init_config_for_env
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
      delete_db_volume
    end

    def shutdown
      @config[:shared_names].each do |_, container_name|
        killrm container_name
      end
      run_command "docker network rm #{@config[:networkname]}"
      run_command "docker volume rm #{@config[:shared_names][:certs]}"
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
      FileUtils.rm db_image_path('.default')
      setup_db
    end

    def attach
      ensure_setup
      cmd = ARGV.shift || ''
      killrm app_container_name

      system "docker run -ti
        --name #{app_container_name}
        --network #{network_name}
        -p #{app_port}:#{app_expose}
        -e DEV_APPLICATION_HOST=#{envname}.localhost.labs.degica.com
        -e VIRTUAL_HOST=#{envname}.localhost.labs.degica.com
        -e VIRTUAL_PORT=#{app_expose}
        #{app_params}
        kaiser:#{current_branch} #{cmd}".tr("\n", ' ')

      @out.puts "Cleaning up..."
      start_app
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

      status = run_command "docker run -ti
        --name #{envname}-apptemp
        --network #{@config[:networkname]}
        #{app_params}
        kaiser:#{current_branch} #{db_reset_command}"

      if status != 0
        @infoout.puts "#{envname} db provision failed"
        exit!
      end
      killrm "#{envname}-apptemp"
      save_db(".default")
    end

    def save_db(name)
      killrm db_container_name
      save_db_state_from(container: db_volume_name, to_file: db_image_path(name))
      start_db
    end

    def load_db(name)
      Optimist.die 'No saved state exists with that name' unless File.exist?(db_image_path(name))
      killrm db_container_name
      run_command "docker volume rm #{db_volume_name}"
      create_if_volume_not_exist db_volume_name
      load_db_state_from(file: db_image_path(name), to_container: db_volume_name)
      start_db
    end

    def save_db_state_from(container:, to_file:)
      @out.puts 'Saving database state'
      File.write(to_file, '')
      run_command "docker run --rm
        -v #{container}:#{db_data_directory}
        -v #{to_file}:#{to_file}
        ruby:alpine
        tar cvjf #{to_file} #{db_data_directory}"
    end

    def load_db_state_from(file:, to_container:)
      @out.puts 'Loading database state'
      run_command "docker run --rm
        -v #{to_container}:#{db_data_directory}
        -v #{file}:#{file}
        ruby:alpine
        tar xvjf #{file} -C #{db_data_directory} --strip #{db_data_directory.scan(%r{\/}).count}"
    end

    def stop_db
      killrm db_container_name
    end

    def start_db
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
      run_command "docker volume rm #{db_volume_name}"
    end

    def setup_app
      File.write(tmp_dockerfile_name, docker_file_contents)
      run_command "docker build
        -t kaiser:#{current_branch}
        -f #{tmp_dockerfile_name} #{@work_dir}"
      FileUtils.rm(tmp_dockerfile_name)
    end

    def current_branch_db_image_dir
      "#{config_dir}/databases/#{envname}/#{current_branch}"
    end

    def db_image_path(name)
      FileUtils.mkdir_p current_branch_db_image_dir
      "#{current_branch_db_image_dir}/#{name}.tar.bz"
    end

    def default_db_image
      db_image_path('.default')
    end

    def start_app
      killrm app_container_name
      run_command "docker run -d
        --name #{app_container_name}
        --network #{network_name}
        -p #{app_port}:#{app_expose}
        -e DEV_APPLICATION_HOST=#{envname}.localhost.labs.degica.com
        -e VIRTUAL_HOST=#{envname}.localhost.labs.degica.com
        -e VIRTUAL_PORT=#{app_expose}
        #{app_params}
        kaiser:#{current_branch}"
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

    def wait_for_db
      @out.puts "Waiting for database to start..."

      File.write(tmp_waitscript_name, db_waitscript)

      killrm tmp_db_waiter
      run_command "docker run --rm -ti
        --name #{tmp_db_waiter}
        --network #{network_name}
        -v #{tmp_waitscript_name}:/wait.sh
        #{db_waitscript_params}
        #{db_image} bash /wait.sh"

      FileUtils.rm(tmp_waitscript_name)

      @out.puts "Started."
    end

    def config_dir
      @config_dir
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

    def db_waitscript
      eval_template @kaiserfile.database[:waitscript]
    end

    def db_waitscript_params
      eval_template @kaiserfile.database[:waitscript_params]
    end

    def docker_file_contents
      eval_template @kaiserfile.docker_file_contents
    end

    def app_params
      eval_template @kaiserfile.params
    end

    def db_reset_command
      eval_template @kaiserfile.database_reset_command
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
      "#{envname}-app"
    end

    def db_container_name
      "#{envname}-db"
    end

    def current_branch
      `git branch | grep \\* | cut -d ' ' -f2`.chomp
    end

    def ensure_env
      Optimist.die 'No environment? Please use kaiser init <name>' if envname.nil?
    end

    def ensure_setup
      ensure_env

      setup if network.nil?
      create_if_volume_not_exist @config[:shared_names][:certs]
      create_if_network_not_exist @config[:networkname]
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

    def run_command(cmd, until_match:nil)
      cmd.gsub! "\n", ' '
      @out.puts "> #{cmd}"
      begin
        PTY.spawn("#{cmd} 2>&1") do |stdout, stdin, pid|
          begin
            # Do stuff with the output here. Just printing to show it works
            stdout.each do |line|
              @out.print line
              if until_match
                if until_match.match(line)
                  `kill #{pid}`
                end
              end
              @out.flush
            end
          rescue Errno::EIO
            @out.puts "$? = 0"
            @out.flush
            return 0
          end
        end
        return 0
      rescue PTY::ChildExited => ex
        @out.puts "The child process exited with code #{ex.status}"
        @out.flush
        return ex.status
      end
    end

    def network
      `docker network inspect #{@config[:networkname]}`
    end

    def if_container_dead(container, &block)
      x = JSON.parse(`docker inspect #{container}`)
      return unless x.length.zero? || x[0]['State']['Running'] == false
      yield if block
    end

    def create_if_volume_not_exist(vol)
      x = JSON.parse(`docker volume inspect #{vol}`)
      return unless x.length.zero?
      run_command "docker volume create #{vol}"
    end

    def create_if_network_not_exist(net)
      x = JSON.parse(`docker inspect #{net}`)
      return unless x.length.zero?
      run_command "docker network create #{net}"
    end

    def run_if_dead(container, command)
      if_container_dead container do
        killrm container
        run_command command
      end
    end

    def envname
      @config[:envnames][@work_dir]
    end

    def init_config_for_env
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
      x = JSON.parse(`docker inspect #{container}`)
      return if x.length.zero?
      run_command "docker kill #{container}" if x[0]['State'] && x[0]['State']['Running'] == true
      run_command "docker rm #{container}" if x[0]['State']
    end
  end
end
