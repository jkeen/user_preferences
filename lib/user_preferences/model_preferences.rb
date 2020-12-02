require 'yaml'
require 'active_support'
require 'active_support/core_ext/hash'

module UserPreferences
  class ModelPreferences
    attr_reader :type, :category

    def initialize(type)
      @type = type
    end

    def [](category, name)
      if pref = definitions[category].try(:[], name)
        PreferenceDefinition.new(pref, category, name)
      end
    end

    def defaults(category = nil)
      @_defaults ||= Defaults.new(definitions)
      @_defaults.get(category)
    end

    def yml_path
      File.join(self.class.config_path, "#{@type.to_s.downcase}_preferences.yml")
    end

    def definitions
      @_definitions ||= YAML.load_file(yml_path).with_indifferent_access
    end

    def self.config_path
      File.join(Rails.root, 'config') if defined?(Rails)
    end
  end
end
