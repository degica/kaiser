module Kaiser
  module CMD
    class Logs < Cli

      def usage
      <<EOS
Continuously monitors the application container's logs.

USAGE: kaiser logs
EOS
      end

      def execute
        exec "docker logs -f #{app_container_name}"
      end

    end
  end
end
