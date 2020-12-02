require 'byebug'
class UserPreferences::Preference < ActiveRecord::Base
  self.table_name = 'preferences'
  belongs_to :preferable, polymorphic: true
  validates_uniqueness_of :name, scope: [:preferable_id, :preferable_type, :category]
  validates :category, :name, :preferable_id, :preferable_type, presence: true

  validates :value, inclusion: { in: ->(p) { p.permitted_values }}, if: proc { preferable.present? }

  delegate :binary?, :default, :permitted_values, :lookup, :to_db, to: :definition

  def update_value!(v)
    raise ArgumentError, "definition for #{self.preferable_type} at #{category}/#{name} is not defined" unless definition.present?

    update!(value: v)
  end

  def value
    lookup(attributes['value'])
  end

  def value=(v)
    super(to_db(v))
  end

  def definition
    if preferable_type.present?
      UserPreferences::ModelPreferences.new(preferable_type).try(:[], category, name)
    end
  end
end
