# frozen_string_literal: true

module Kaiser
  class Plugin
    def initialize(kaiserfile)
      @kaiserfile = kaiserfile
    end

    def self.inherited(plugin)
      # underscore class name
      name = plugin.to_s.split('::').last
                   .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                   .gsub(/([a-z\d])([A-Z])/, '\1_\2')
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
