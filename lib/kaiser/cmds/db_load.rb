# frozen_string_literal: true

module Kaiser
  module Cmds
    class DbLoad < Cli
      def usage
        <<~EOS
          Shuts down the database docker container, *replaces* the database with the backup provided and brings the container up again.

          The database will be restored from a tarball saved as \`~/.kaiser/<ENV_NAME>/<current_github_branch_name>/<DB_BACKUP_FILENAME>.tar.bz\`

          Alternatively you can also load it from your current directory.

          If no database name was provided, the default database stored at \`~/.kaiser/<ENV_NAME>/<current_github_branch_name>/default.tar.bz\` will be used.

          USAGE: kaiser db_load
                 kaiser db_load DB_BACKUP_FILENAME
                 kaiser db_load ./my_database.tar.bz
        EOS
      end

      def execute(_opts)
        ensure_setup
        name = ARGV.shift || DEFAULT_DB_FILE
        load_db(name)
      end
    end
  end
end
