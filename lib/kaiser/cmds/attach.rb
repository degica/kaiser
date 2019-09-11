# frozen_string_literal: true

module Kaiser
  module Cmds
    class Attach < Cli
      def usage
        <<~EOS
          Shuts down the application container and starts it up again with the current directory bind mounted inside. This way the application will run from the source code in the current directory and any edits you make will immediately show up inside the container. This is ideal for development.

          USAGE: kaiser attach
        EOS
      end

      def execute
        ensure_setup
        cmd = (ARGV || []).join(' ')
        killrm app_container_name

        volumes = attach_mounts.map { |from, to| "-v #{`pwd`.chomp}/#{from}:#{to}" }.join(' ')

        system "docker run -ti
          --name #{app_container_name}
          --network #{network_name}
          --dns #{ip_of_container(Config.config[:shared_names][:dns])}
          --dns-search #{http_suffix}
          -p #{app_port}:#{app_expose}
          -e DEV_APPLICATION_HOST=#{envname}.#{http_suffix}
          -e VIRTUAL_HOST=#{envname}.#{http_suffix}
          -e VIRTUAL_PORT=#{app_expose}
          #{volumes}
          #{app_params}
          kaiser:#{envname}-#{current_branch} #{cmd}".tr("\n", ' ')

        Config.out.puts 'Cleaning up...'
        start_app
      end

      def attach_mounts
        Config.kaiserfile.attach_mounts
      end
    end
  end
end
