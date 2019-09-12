# frozen_string_literal: true

module Kaiser
  module Cmds
    class Set < Cli
      def usage
        <<~EOS
          This command lets you set up special variables that configure kaiser's behavior for you.

          Available subcommands:

          http-suffix - Sets the domain suffix for the reverse proxy to use (defaults to lvh.me)
          cert-url    - Sets up a URL from which HTTPS certificates can be downloaded.
          cert-folder - Sets up a folder from which HTTPS certificates can be copied.
          help-https  - Shows the HTTPS notes.

          USAGE: kaiser set cert-url
                 kaiser set cert-folder
                 kaiser set http-suffix
                 kaiser set help-https
        EOS
      end

      def execute
        ARGV.shift # Remove the set command itself
        cmd = ARGV.shift # Get the subcommand
        if cmd == 'cert-url'
          Config.config[:cert_source] = {
            url: ARGV.shift
          }
        elsif cmd == 'cert-folder'
          Config.config[:cert_source] = {
            folder: ARGV.shift
          }
        elsif cmd == 'http-suffix'
          Config.config[:http_suffix] = ARGV.shift
        elsif cmd == 'help-https'
          puts <<~SET_HELP
            Notes on HTTPS:

            You need to set suffix and either cert-url or cert-folder to enable HTTPS.

            cert-url and cert-folder are mutually exclusive. If you set one of them the other will be erased.

            The cert-url and cert-folder must satisfy the following requirements to work:

            The strings must be the root of certificates named after the suffix. For example,

              if cert-url is https://mydomain.com/certs and your suffix is local.mydomain.com, the following
              url need to be the certificate files:

              https://mydomain.com/certs/local.mydomain.com.chain.pem
              https://mydomain.com/certs/local.mydomain.com.crt
              https://mydomain.com/certs/local.mydomain.com.key

            Another example:

              If you use suffix of localme.com and cert-folder is /home/me/https, The following files need to exist:

              /home/me/https/localme.com.chain.pem
              /home/me/https/localme.com.crt
              /home/me/https/localme.com.key
          SET_HELP
        else
          Optimist.die "Unknown subcommand: '#{cmd}'"
        end
        save_config
      end
    end
  end
end
