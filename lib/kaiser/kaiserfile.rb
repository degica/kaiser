# frozen_string_literal: true

module Kaiser
  # This class is responsible for parsing the Kaiserfile
  class Kaiserfile
    attr_accessor :docker_file_contents,
                  :docker_build_args,
                  :database,
                  :platform,
                  :port,
                  :database_reset_command,
                  :attach_mounts,
                  :server_type,
                  :services

    def initialize(filename)
      Optimist.die 'No Kaiserfile in current directory' unless File.exist? filename

      @database = {
        image: 'none',
        platform: '',
        port: 1234,
        data_dir: '/tmp/data',
        params: '',
        commands: 'echo "no db"',
        waitscript: 'echo "no dbwait"',
        waitscript_params: ''
      }
      @attach_mounts = []
      @params_array = []
      @server_type = :unknown
      @database_reset_command = 'echo "no db to reset"'
      @port = 1234
      @services = {}

      instance_eval File.read(filename), filename
    end

    def validate!
      raise 'No dockerfile specified.' if @docker_file_contents.nil?
    end

    def plugin(name)
      require "kaiser/plugins/#{name}"
      raise "Plugin #{name} is not loaded." unless Plugin.loaded?(name)

      Plugin.all_plugins[name].new(self).on_init
    end

    def dockerfile(name, options = {})
      @docker_file_contents = File.read(name)
      @docker_build_args = options[:args] || {}
    end

    def attach_mount(from, to)
      attach_mounts << [from, to]
    end

    def db(image,
           data_dir:,
           port:,
           platform: '',
           params: '',
           commands: '',
           waitscript: nil,
           waitscript_params: '')
      @database = {
        image: image,
        platform: platform,
        port: port,
        data_dir: data_dir,
        params: params,
        commands: commands,
        waitscript: waitscript,
        waitscript_params: waitscript_params
      }
    end

    def force_platform(platform_name)
      @platform = platform_name
    end

    def expose(port)
      @port = port
    end

    def app_params(value)
      @params_array << value
    end

    def params
      @params_array.join(' ')
    end

    def db_reset_command(value)
      @database_reset_command = value
    end

    def type(value)
      raise 'Valid server types are: [:http]' if value != :http

      @server_type = value
    end

    def service(name,
                image: name,
                command: nil,
                binds: {},
                env: {})

      raise "duplicate service #{name.inspect}" if @services.key?(name)

      @services[name] = {
        image: image,
        command: command,
        binds: binds,
        env: env
      }
    end
  end
end
