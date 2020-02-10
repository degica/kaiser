module Kaiser
  module Cmds
    class Sudo < Cli
      def usage
        <<~USAGE
          Runs command AS ROOT without setting up

          USAGE: kaiser sudo echo hello there
        USAGE
      end

      def execute(_opts)
        attach_app
      end

      def app_params
        [super, '--user=root'].join("\n")
      end

      # Don't take options - consume the whole command line
      def define_options(*)
        {}
      end
    end
  end
end
