# frozen_string_literal: true

module Kaiser
  class Ruby < Plugin
    def on_init
      app_params default_volumes
    end

    private

    def container_ruby_version
      dockerfile = @kaiserfile.docker_file_contents
      /FROM (?<container_base>[^\s]+)/ =~ dockerfile.each_line.first
      raise 'Ruby plugin cannot parse dockerfile' if container_base.nil?

      `docker run --rm -it #{container_base} ruby -e 'puts RUBY_VERSION'`.chomp
    end

    def default_volumes
      ruby_version = container_ruby_version.gsub(/[\.\s]/, '-')

      <<~VOLUMES
      -v kaiser-bundle-#{ruby_version}:/usr/local/bundle
      -v kaiser-gems-#{ruby_version}:/root/.gem/specs
      VOLUMES
    end
  end
end
