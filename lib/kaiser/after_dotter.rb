module Kaiser
  # Prints properly after a dotter prints
  class AfterDotter
    def initialize(channel: $stderr, dotter:)
      @channel = channel
      @dotter = dotter
    end

    def puts(value)
      if @dotter.dotted
        @dotter.dotted = false
        @channel.puts ''
      end
      @channel.puts(value)
    end

    def flush
      @channel.flush
    end
  end
end
