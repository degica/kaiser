module Kaiser
  module CMD
    class Deinit < KaiserCli

      def usage
      <<EOS
Removes the Kaiser environment from `~/.kaiser/.config.yml`. This however does not delete the `~/.kaiser/databases/<ENV_NAME>` directory.

Usage: kaiser init ENV_NAME
EOS
      end

      def execute
        down
        Config.config[:envs].delete(envname)
        Config.config[:envnames].delete(Config.work_dir)
        save_config
      end

      def down
        stop_db
        stop_app
        delete_db_volume
      end

      def stop_app
        Config.info_out.puts 'Stopping application'
        killrm app_container_name
      end

    end
  end
end
