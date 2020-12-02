module UserPreferences
  module HasPreferences
    extend ActiveSupport::Concern

    module ActiveRecordExtension
      def has_preferences
        include HasPreferences
      end
    end

    included do
      has_many :saved_preferences, class_name: 'UserPreferences::Preference', dependent: :destroy, as: :preferable

      def preferences(category)
        @_preference_apis ||= {}
        @_preference_apis[category] ||= UserPreferences::API.new(category, saved_preferences)
      end

      def self.preferences
        UserPreferences::ModelPreferences.new(self)
      end

      def self.definitions
        self.preferences.definitions
      end

      def self.defaults(category = null)
        UserPreferences::ModelPreferences.new(self).defaults(category)
      end

      def self.with_preference(category, name, value)
        definition = self.preferences[category, name]
        db_value = definition.to_db(value)
        join = %Q{
          %s join #{UserPreferences::Preference.table_name} p
          on p.category = '#{category}' and p.name = '#{name}'
          and p.preferable_id = #{self.table_name}.id
          and p.preferable_type = '#{self.to_s}'
        }

        if value != definition.default
          joins(join % 'inner').where("p.value = #{db_value}")
        else
          joins(join % 'left').where("p.value = #{db_value} or p.id is null")
        end
      end
    end
  end
end
