# frozen_string_literal: true

module Kaiser
  class Config
    class << self
      attr_reader :work_dir,
                  :config_dir,
                  :config_file,
                  :kaiserfile,
                  :config,
                  :out,
                  :info_out

      attr_writer :out,
                  :info_out

      def load(work_dir)
        @work_dir = work_dir
        @config_dir = "#{ENV['HOME']}/.kaiser"

        FileUtils.mkdir_p @config_dir
        @config_file = "#{@config_dir}/.config.yml"
        @kaiserfile = Kaiserfile.new("#{@work_dir}/Kaiserfile")

        @config = {
          envnames: {},
          envs: {},
          networkname: 'kaiser_net',
          shared_names: {
            redis: 'kaiser-redis',
            nginx: 'kaiser-nginx',
            chrome: 'kaiser-chrome',
            dns: 'kaiser-dns',
            certs: 'kaiser-certs'
          },
          largest_port: 9000,
          always_verbose: false,
          host_shell_rc: "#{ENV['HOME']}/.kaiser_profile",
          always_login_shell: true
        }

        load_config
        initialize_kaiser_profile
      end

      def always_verbose?
        @config[:always_verbose]
      end

      def always_login_shell?
        @config[:always_login_shell]
      end

      def host_shell_rc
        @config[:host_shell_rc]
      end

      def container_shell_rc
        kaiserfile.shell_rc_path
      end

      def load_config
        loaded = YAML.load_file(@config_file) if File.exist?(@config_file)

        config_shared_names = @config[:shared_names] if @config
        loaded_shared_names = loaded[:shared_names] if loaded

        @config = {
          **(@config || {}),
          **(loaded || {}),
          shared_names: { **(config_shared_names || {}), **(loaded_shared_names || {}) }
        }
      end

      def initialize_kaiser_profile
        return if File.exist?(host_shell_rc)

        default_shell_rc = File.join(__dir__, 'files', 'default_kaiser_profile.bash')
        FileUtils.cp default_shell_rc, host_shell_rc
      end
    end
  end
end
