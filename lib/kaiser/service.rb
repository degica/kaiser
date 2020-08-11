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
  end
end
