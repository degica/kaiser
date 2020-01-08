module Kaiser
  module Cmds
    class Do < Cli
      def usage
        <<~EOS
          Runs command without setting up

          USAGE: kaiser do echo hello there
        EOS
      end

      def execute(_opts)
        attach_app
      end

      # Don't take options - consume the whole command line
      def define_options(*)
        {}
      end
    end
  end
end
