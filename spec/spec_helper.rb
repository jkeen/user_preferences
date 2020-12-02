require 'user_preferences'
require 'active_record'
require 'active_record/connection_adapters/sqlite3_adapter'

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_persistence"
  $stdout = StringIO.new # silence migrations
  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
  if ActiveRecord::VERSION::MAJOR >= 5
    ActiveRecord::Migrator.migrations_paths = File.expand_path('../migrations', __FILE__)
    ActiveRecord::Base.connection.migration_context.migrate
  else
    ActiveRecord::Migrator.migrate(File.expand_path('../migrations', __FILE__))
  end
  $stdout = STDOUT

  # prevent deprecation warnings
  I18n.enforce_available_locales = true

  config.mock_with :rspec do |mocks|
    mocks.syntax = [:should, :expect]
  end
  config.before(:each) { stub_yml }
end

def stub_yml
  UserPreferences::ModelPreferences.stub(:config_path).and_return(File.expand_path("./spec/fixtures"))
end

class User < ActiveRecord::Base
  include UserPreferences::HasPreferences
end

class Admin < ActiveRecord::Base
  include UserPreferences::HasPreferences
end

