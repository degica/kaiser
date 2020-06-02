# frozen_string_literal: true

module Kaiser
  # This class is responsible for parsing the Kaiserfile
  class Kaiserfile
    HOME = ENV['HOME']

    attr_accessor :docker_file_contents,
                  :docker_build_args,
                  :database,
                  :port,
                  :database_reset_command,
                  :attach_mounts,
                  :shell_rc,
                  :server_type

    def initialize(filename)
      Optimist.die 'No Kaiserfile in current directory' unless File.exist? filename

      @shell_rc = '/etc/profile'
      @databases = {}
      @attach_mounts = []
      @params_array = []
      @server_type = :unknown

      instance_eval File.read(filename), filename
    end

    def plugin(name)
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

    def shell_rc_path
      shell_rc
    end

    def container_shell_rc(value)
      self.shell_rc = value
    end

    def db(image,
           data_dir:,
           port:,
           params: '',
           commands: '',
           waitscript: nil,
           waitscript_params: '')
      @database = {
        image: image,
        port: port,
        data_dir: data_dir,
        params: params,
        commands: commands,
        waitscript: waitscript,
        waitscript_params: waitscript_params
      }
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
  end
end
