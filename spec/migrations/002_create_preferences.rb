class CreatePreferences < (ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration)
  def self.up
    create_table :preferences do |t|
      t.references :preferable, polymorphic: true, null:false
      t.string  :category, null: false
      t.string  :name, null: false
      t.integer :value, null: false
      t.timestamps
    end

    add_index :preferences, :preferable_id
    add_index :preferences, [:preferable_id, :preferable_type, :category], name: 'index_preferences_on_reference_and_category'
    add_index :preferences, [:category, :name, :value]
  end


  def self.down
    drop_table :preferences
  end
end
