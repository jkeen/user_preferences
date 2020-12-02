require 'spec_helper'
require 'yaml'

describe "ModelPreferences" do
  describe '.[]' do
    it 'returns a preference definition instance for supplied category and name' do
      result = User.preferences[:food, :wine]
      expect(result).to be_kind_of(UserPreferences::PreferenceDefinition)
      expect(result.category).to eq(:food)
      expect(result.name).to eq(:wine)
      expect(result.default).to eq('red')
    end

    context "the category doesn't exist" do
      it 'returns nil' do
        expect(User.preferences[:fashion, :hats]).to be_nil
      end
    end

    context "the name doesn't exist" do
      it 'returns nil' do
        expect(User.preferences[:food, :dressing]).to be_nil
      end
    end
  end

  describe '.defaults' do
    it 'returns the defaults from definitions' do
      expect_any_instance_of(UserPreferences::Defaults).to receive(:get)
      User.defaults(:food)
    end
  end

  describe '.definitions' do
    it 'returns the loaded preference yml' do
      file = File.expand_path("../fixtures/user_preferences.yml", __FILE__)
      expect(User.definitions).to eq(YAML.load_file(file).with_indifferent_access)
    end
  end
end