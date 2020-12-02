require 'yaml'
require 'active_support'
require 'active_support/core_ext/hash'

module UserPreferences
  extend ActiveSupport::Autoload

  autoload :API, 'user_preferences/api'
  autoload :Defaults
  autoload :HasPreferences
  autoload :Preference
  autoload :PreferenceDefinition
  autoload :ModelPreferences
  autoload :VERSION

  class << self
    delegate :[], :defaults, :yml_path, :definitions, to: :default_type 
    
    private

    # For backwards compatibility when UserPreferences didn't support polymorphism
    def default_type
      Rails.logger.info 'DEPRECATED: calling UserPreferences directly is deprecated. Move your calls to the model. i.e. User.preferences' if defined?(Rails)
      User.preferences
    end
  end
end

require 'user_preferences/railtie' if defined?(Rails)