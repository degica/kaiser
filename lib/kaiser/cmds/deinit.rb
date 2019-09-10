module Kaiser
  module CMD
    class Deinit < Cli

      def usage
      <<EOS
Removes the Kaiser environment from `~/.kaiser/.config.yml`. This however does not delete the `~/.kaiser/databases/<ENV_NAME>` directory.

USAGE: kaiser init ENV_NAME
EOS
      end

      def execute
        down
        Config.config[:envs].delete(envname)
        Config.config[:envnames].delete(Config.work_dir)
        save_config
      end

    end
  end
end
