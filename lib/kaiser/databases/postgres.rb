# frozen_string_literal: true

module Kaiser
  module Databases
    class Postgres
      def initialize(options)
        @options = options
      end

      def options_hash
        testpass = @options[:root_password] || 'testpassword'
        parameters = @options[:parameters] || ''
        port = @options[:port] || 3306

        {
          port: port,
          data_dir: '/var/lib/postgresql/data',
          params: "-e POSTGRES_PASSWORD=#{testpass}",
          commands: parameters,
          waitscript_params: "
            -e PG_HOST=<%= db_container_name %>
            -e PG_USER=postgres
            -e PGPASSWORD=#{testpass}
            -e PG_DATABASE=postgres",
          waitscript: <<~SCRIPT
            #!/bin/sh

            RETRIES=5

            until psql -h $PG_HOST -U $PG_USER -d $PG_DATABASE -c "select 1" > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
             echo "Waiting for postgres server, $((RETRIES--)) remaining attempts..."
             sleep 1
            done
          SCRIPT
        }
      end

      def image_name
        version = @options[:version] || 'alpine'
        "postgres:#{version}"
      end
    end
  end
end
