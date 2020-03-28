# frozen_string_literal: true

module Kaiser
  # To implement a Kaiser plugin you must inherit from this class.
  # For example,
  #
  #   class MyPlugin < Plugin
  #     def on_init
  #       puts 'My plugin is loaded!'
  #     end
  #   end
  #
  # Then in your Kasierfile
  #
  #   plugin :my_plugin
  #
  # Plugins has access the Kaiserfile DSL. For example,
  #
  #   class Ruby < Plugin
  #     def on_init
  #       attach_mount 'Gemfile', '/usr/app/Gemfile'
  #       attach_mount 'Gemfile.lock', '/usr/app/Gemfile.lock'
  #     end
  #   end
  #
  class Plugin
    def initialize(kaiserfile)
      @kaiserfile = kaiserfile
    end

    def self.loaded?(name)
      Plugin.all_plugins.key?(name)
    end

    def self.inherited(plugin)
      # underscore class name
      name = plugin.to_s.split('::').last
                   .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                   .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                   .gsub(/([a-z])(\d)/, '\1_\2')
                   .tr('-', '_').downcase

      Plugin.all_plugins[name.to_sym] = plugin
    end

    def self.all_plugins
      @all_plugins ||= {}
    end

    def on_init
      raise 'Please implement #on_init'
    end

    def method_missing(method_sym, *arguments, &block) # rubocop:disable all
      @kaiserfile.send(method_sym, *arguments, &block)
    end
  end
end
