# frozen_string_literal: true

module Kaiser
  # This class describes an app-specific service
  class Service
    def initialize(envname, service_info)
      @envname = envname
      @service_info = service_info
    end

    def name
      @service_info.keys.first
    end

    def shared_name
      "#{@envname}-#{name}"
    end

    def image
      @service_info.values.first[:image]
    end
  end
end
