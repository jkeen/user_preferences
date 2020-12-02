module UserPreferences
  module Generators
    class UpgradeGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)

      def copy_migrations
        migration_template 'migration.rb.erb', "db/migrate/upgrade_user_preferences.rb"
      end

      # TODO get rid of this
      def self.next_migration_number(dir)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end
    end
  end
end