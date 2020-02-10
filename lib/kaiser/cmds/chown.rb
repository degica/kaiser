# frozen_string_literal: true

module Kaiser
  module Cmds
    # Shitty quick fix for me
    class Chown < Cli
      def usage
        <<~USAGE
          Changes the owner of the cached gem directories to be the specified user...

          USAGE: kaiser chown USERNAME
        USAGE
      end

      def execute(_opts)
        username = ARGV.shift

        cmd = "sh -c 'chown -R #{username} /usr/local/bundle /usr/local/lib/ruby'"

        CommandRunner.run! Config.out, "docker run -d
          --name #{app_container_name}
          --network #{network_name}
          --dns #{ip_of_container(Config.config[:shared_names][:dns])}
          --dns-search #{http_suffix}
          -p #{app_port}:#{app_expose}
          -e KAISER_NAME=#{envname}
          -e DEV_APPLICATION_HOST=#{envname}.#{http_suffix}
          -e VIRTUAL_HOST=#{envname}.#{http_suffix}
          -e VIRTUAL_PORT=#{app_expose}
          --user=root
          #{attach_volumes}
          #{default_volumes}
          #{app_params}
          kaiser:#{envname} #{cmd}"
      end
    end
  end
end
