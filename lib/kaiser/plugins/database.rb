# frozen_string_literal: true

require 'active_support/inflector'

module Kaiser
  module Plugins
    class Database < Plugin
      def on_init
        @kaiserfile.define_singleton_method :def_db do |*args|
          args[0] = { args.first => {} } unless args.first.is_a? Hash

          option = args.first

          driver_name = option.keys.first.to_s

          begin
            require "kaiser/databases/#{driver_name}"
          rescue LoadError
            raise "Unknown database '#{driver_name}'"
          end

          driver_class = Kaiser::Databases.const_get(driver_name.camelize)
          db_driver = driver_class.new(option.values.first)

          db(db_driver.image_name, **db_driver.options_hash)
        end
      end
    end
  end
end
