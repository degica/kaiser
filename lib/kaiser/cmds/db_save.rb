# frozen_string_literal: true

module Kaiser
  module Cmds
    class DbSave < Cli
      def usage
        <<~EOS
          Shuts down the database docker container, backs up the database and brings the container back up.

          The database will be saved as a tarball to \`~/.kaiser/<ENV_NAME>/<current_github_branch_name>/<DB_BACKUP_FILENAME>.tar.bz\`

          Alternatively you can also save it to your current directory.

          USAGE: kaiser db_save DB_BACKUP_FILENAME
                 kaiser db_save ./my_database.tar.bz
        EOS
      end

      def execute(opts)
        ensure_setup
        name = ARGV.shift || '.default'
        save_db(name)
      end
    end
  end
end
