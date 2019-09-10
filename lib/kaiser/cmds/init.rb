
module Kaiser
  module CMD
    class Init < Cli
      #TODO: Add explanation for the Already initialized error.
      def usage
        <<EOS
Initializes a Kaiser environment and assigns ports for it in `~/.kaiser/.config.yml`. When running `kaiser up` later the directory `~/.kaiser/databases/<ENV_NAME>`  will get created.

USAGE: kaiser init ENV_NAME
EOS
      end

      def execute
        return Optimist.die "Already initialized as #{envname}" if envname

        name = ARGV.shift
        return Optimist.die 'Needs environment name' if name.nil?

        init_config_for_env(name)
        save_config
      end

      def init_config_for_env(name)
        Config.config[:envnames][Config.work_dir] = name
        Config.config[:envs][name] = {
          app_port: (largest_port + 1).to_s,
          db_port: (largest_port + 2).to_s
        }
        Config.config[:largest_port] = Config.config[:largest_port] + 2
      end

      def largest_port
        Config.config[:largest_port]
      end

    end
  end
end
