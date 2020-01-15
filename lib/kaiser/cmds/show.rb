# frozen_string_literal: true

module Kaiser
  module Cmds
    class Show < Cli
      def usage
        <<~EOS
          Subcommand that shows information about the environment such as the TCP ports or the certificate used for HTTPS.

          USAGE: kaiser show ports
                 kaiser show cert-source
                 kaiser show http-suffix
        EOS
      end

      def execute(_opts)
        ensure_setup
        cmd = ARGV.shift
        valid_cmds = 'ports cert-source http-suffix'
        return Optimist.die "Available things to show: #{valid_cmds}" unless cmd

        if cmd == 'ports'
          Config.info_out.puts "app: #{app_port}"
          Config.info_out.puts "db: #{db_port}"
        elsif cmd == 'cert-source'
          unless Config.config[:cert_source]
            Optimist.die 'No certificate source set.
              see kaiser set help'
          end

          source = Config.config[:cert_source][:url] || Config.config[:cert_source][:folder]
          Config.info_out.puts source
        elsif cmd == 'http-suffix'
          Config.info_out.puts http_suffix
        end
      end
    end
  end
end
