module Kaiser
  module CMD
    class Login < Cli

      def usage
      <<EOS
Executes a command on the application docker container. By executing the command `sh` you can get a login shell.

USAGE: kaiser login COMMAND
EOS
      end

      def execute
        ensure_setup
        cmd = (ARGV || []).join(' ')
        exec "docker exec -ti #{app_container_name} #{cmd}"
      end

    end
  end
end
