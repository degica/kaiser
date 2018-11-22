module Kaiser
  # This class is responsible for parsing the Kaiserfile
  class Kaiserfile
    attr_accessor :docker_file_contents,
                  :database,
                  :port,
                  :params,
                  :database_reset_command

    def initialize(filename)
      @databases = {}
      instance_eval File.read(filename), filename
    end

    def dockerfile(name)
      @docker_file_contents = File.read(name)
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
      @params = value
    end

    def db_reset_command(value)
      @database_reset_command = value
    end
  end
end
