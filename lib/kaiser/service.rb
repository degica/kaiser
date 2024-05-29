# frozen_string_literal: true

module Kaiser
  # This class describes an app-specific service
  class Service
    attr_reader :name

    def initialize(envname, name, service_info)
      @envname = envname
      @name = name
      @service_info = service_info
    end

    def shared_name
      "#{@envname}-#{name}"
    end

    def image
      @service_info[:image]
    end

    def command
      @service_info[:command].to_s
    end

    def binds
      @service_info[:binds] || {}
    end

    def env
      @service_info[:env] || {}
    end

    def start_docker_command
      envstring = env.map do |k,v|
        "-e #{k}=#{v}"
      end.join(' ')

      bindstring = binds.map do |k,v|
        "-v #{k}:#{v}"
      end.join(' ')

      commandstring = command

      cmd_array = [
        "docker run -d",
        "--name #{shared_name}",
        "--network #{Config.config[:networkname]}",
        envstring,
        bindstring,
        image,
        commandstring
      ]

      cmd_array.filter! {|x| !x.empty?}

      cmd_array.join(" ")
    end
  end
end
