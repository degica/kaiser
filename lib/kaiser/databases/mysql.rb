# frozen_string_literal: true

module Kaiser
  module Databases
    class Mysql
      def initialize(options)
        @options = options
      end

      def options_hash
        testpass = @options[:root_password] || 'testpassword'
        parameters = @options[:parameters] || ''
        port = @options[:port] || 3306

        {
          port: port,
          data_dir: '/var/lib/mysql',
          params: "-e MYSQL_ROOT_PASSWORD=#{testpass}",
          commands: parameters,
          waitscript_params: "
            -e MYSQL_ADDR=<%= db_container_name %>
            -e MYSQL_PORT=#{port}
            -e MYSQL_ROOT_PASSWORD=#{testpass}",
          waitscript: <<~SCRIPT
            #!/bin/bash

            echo "Waiting for mysql to start."
            until mysql -h"$MYSQL_ADDR" -P"$MYSQL_PORT" -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1"
            do
              printf "."
              sleep 1
            done

            echo -e "\nmysql started."
          SCRIPT
        }
      end

      def image_name
        version = @options[:version] || '5.6'
        "mysql:#{version}"
      end
    end
  end
end
