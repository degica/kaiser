# frozen_string_literal: true

module Kaiser
  module Cmds
    class Shutdown < Cli
      def usage
        # TODO: Explain a bit more about what these containers do and what shutting
        #      them down really means for an end user.
        <<~EOS
          Shuts down all the containers used internally by Kaiser.

          USAGE: kaiser shutdown
        EOS
      end

      def execute(_opts)
        Config.config[:shared_names].each_value do |container_name|
          killrm container_name
        end

        CommandRunner.run Config.out, "docker network rm #{Config.config[:networkname]}"
        CommandRunner.run Config.out, "docker volume rm #{Config.config[:shared_names][:certs]}"
      end
    end
  end
end
