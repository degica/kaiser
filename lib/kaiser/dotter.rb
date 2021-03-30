# frozen_string_literal: true

module Kaiser
  # Prints dots for every line printed
  class Dotter
    attr_accessor :dotted

    def method_missing(name, *value)
      $stderr.print '.'
      @dotted = true
      super unless @dotted
    end

    # rubocop:disable Lint/UselessMethodDefinition
    def respond_to_missing?(name)
      super
    end
    # rubocop:enable Lint/UselessMethodDefinition
  end
end
