module Kaiser
  module CMD
    class Down < Cli

      def usage
           <<EOS
Shuts down and *deletes* the containers that were started using `kaiser up`.

Usage: kaiser down
EOS
      end

      def execute
        down
      end
    end
  end
end
