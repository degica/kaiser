module Kaiser
  module CMD
    class DbReset < Cli

      def usage
     <<EOS
Shuts down the database docker container, *replaces* the database with the default database image stored at `~/.kaiser/<ENV_NAME>/<current_github_branch_name>/.default.tar.bz` and brings the container up again.

This is the same as running `kaiser db_load` with no arguments.

USAGE: kaiser db_reset
EOS
      end

      def execute
        ensure_setup
        load_db('.default')
      end

    end
  end
end
