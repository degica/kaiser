# frozen_string_literal: true

module Kaiser
  class Cli
    module Volumes
      def ensure_db_volume
        create_if_volume_not_exist db_volume_name
      end

      def delete_db_volume
        CommandRunner.run Config.out, "docker volume rm #{db_volume_name}"
      end

      def tmp_file_volume
        "#{envname}-tmpfiles-vol"
      end

      def default_volumes
        shared = "#{ENV['HOME']}/kaisershare"

        volumes = []
        volumes << "-v #{shared}:/kaisershare\n" if File.exist?(shared)

        volumes.join(' ')
      end

      def db_volume_name
        "#{envname}-database"
      end

      def prepare_cert_volume!
        create_if_volume_not_exist Config.config[:shared_names][:certs]
        return unless Config.config[:cert_source]

        %w[
          chain.pem
          crt
          key
        ].each do |file_ext|
          copy_keyfile("#{http_suffix}.#{file_ext}")
        end
      end

      def create_if_volume_not_exist(vol)
        x = JSON.parse(`docker volume inspect #{vol} 2>/dev/null`)
        return unless x.length.zero?

        CommandRunner.run! Config.out, "docker volume create #{vol}"
      end

      private

      def copy_keyfile(file)
        if Config.config[:cert_source][:folder]
          CommandRunner.run! Config.out, "docker run --rm
          -v #{Config.config[:shared_names][:certs]}:/certs
          -v #{Config.config[:cert_source][:folder]}:/cert_source
          alpine cp /cert_source/#{file} /certs/#{file}"

        elsif Config.config[:cert_source][:url]
          CommandRunner.run! Config.out, "docker run --rm
          -v #{Config.config[:shared_names][:certs]}:/certs
          alpine wget #{Config.config[:cert_source][:url]}/#{file}
            -O /certs/#{file}"
        end
      end
    end
  end
end
