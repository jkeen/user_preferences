class CreatePreferables < (ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration)
  def self.up
    create_table :users do |t|
      t.timestamps null: false
    end

    create_table :admins do |t|
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :users
    drop_table :admins
  end
end
