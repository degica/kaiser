# frozen_string_literal: true

module Kaiser
  module Cmds
    class Attach < Cli
      def usage
        <<~EOS
          Shuts down the application container and starts it up again with the current directory bind mounted inside. This way the application will run from the source code in the current directory and any edits you make will immediately show up inside the container. This is ideal for development.

          Once the attached container exits (through the use of control+c for example) it will be replaced by a regular non-attached version of the app container.

          USAGE: kaiser attach
        EOS
      end

      def execute
        ensure_setup
        attach_app
        start_app
      end
    end
  end
end
