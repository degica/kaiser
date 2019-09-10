module Kaiser
  module CMD
    class Shutdown < Cli

      def usage
        "FORGOT TO ADD DOCUMENATION FOR SHUTDOWN. ADD IT!"
      end

      def execute
        Config.config[:shared_names].each do |_, container_name|
          killrm container_name
        end
        CommandRunner.run Config.out, "docker network rm #{Config.config[:networkname]}"
        CommandRunner.run Config.out, "docker volume rm #{Config.config[:shared_names][:certs]}"
      end

    end
  end
end
