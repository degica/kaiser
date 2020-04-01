# frozen_string_literal: true

module Kaiser
  module Cmds
    class Root < Cli
      def usage
        <<~USAGE
          Executes a command on the application docker container as a root user.

          USAGE: kaiser root COMMAND
        USAGE
      end

      def execute(_opts)
        ensure_setup
        cmd = (ARGV || []).join(' ')
        exec "docker exec -ti --user root #{app_container_name} #{cmd}"
      end
    end
  end
end
