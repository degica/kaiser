# frozen_string_literal: true

module Kaiser
  module CliOptions
    def option(*option)
      @options ||= []
      @options << option
    end

    def options
      @options || []
    end
  end
end
