# frozen_string_literal: true

module Kaiser
  module Cmds
    class Up < Cli
      option :attach, "Bind mount the current source code directory in the app container (as the \`kaiser attach\` command would)", short: '-a'

      def usage
        <<~EOS
          Boots up the application in docker as defined in the \`Kaiserfile\` in its source code. Usually this will create two docker containers \`<ENV_NAME>-db\` and \`<ENV_NAME>-app\` running your database and application respectively.

          A backup of the default database is created and saved to \`~/.kaiser/<ENV_NAME>/<current_github_branch_name>/default.tar.bz\`. This can be restored at any time using the \`db_reset\` command.

          USAGE: kaiser up
        EOS
      end

      def execute(opts)
        ensure_setup
        setup_app
        setup_db

        if opts[:attach]
          attach_app
        else
          start_app
        end
      end

      def setup_app
        Config.info_out.puts 'Setting up application'
        File.write(tmp_dockerfile_name, docker_file_contents)
        build_args = docker_build_args.map { |k, v| "--build-arg #{k}=#{v}" }
        CommandRunner.run! Config.out, "docker build
          -t kaiser:#{envname}
          -f #{tmp_dockerfile_name} #{Config.work_dir}
          #{build_args.join(' ')}"
        FileUtils.rm(tmp_dockerfile_name)
      end
    end
  end
end
