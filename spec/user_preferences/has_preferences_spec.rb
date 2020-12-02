require 'spec_helper'

describe UserPreferences::HasPreferences do
  let(:user) { User.create }
  let(:admin) { Admin.create }

  it 'should mix in preference methods' do
    expect(user).to respond_to(:saved_preferences)
    expect(user).to respond_to(:preferences)

    expect(admin).to respond_to(:saved_preferences)
    expect(admin).to respond_to(:preferences)
  end

  describe '#preferences' do
    it 'should return an API instance' do
      expect(user.preferences(:food)).to be_kind_of(UserPreferences::API)
      expect(admin.preferences(:food)).to be_kind_of(UserPreferences::API)
    end
  end

  describe '.with_preference' do
    before(:each) { 
      User.destroy_all 
      Admin.destroy_all
    }

    it 'only returns users with the matching preference' do
      admin = Admin.create
      admin.preferences(:food).set(wine: 'white')

      user_1, user_2 = 2.times.map { User.create }
      user_1.preferences(:food).set(wine: 'white')
      user_2.preferences(:food).set(wine: 'red')
      expect(User.with_preference(:food, :wine, 'white')).to eq([user_1])

      user_2.preferences(:food).set(wine: 'white')
      expect(User.with_preference(:food, :wine, 'white')).to eq([user_1, user_2])
    end

    it 'returns a chainable active record relation' do
      user.preferences(:food).set(wine: 'white')
      expect(User.with_preference(:food, :wine, 'white')).to be_kind_of(ActiveRecord::Relation)
      expect(User.with_preference(:food, :wine, 'white').where('1=1')).to eq([user])
    end

    context 'the desired preference matches the default value' do
      it 'includes users who have not explicitly overriden the preference' do
        user.preferences(:food).set(wine: 'red') # the default value
        user_2 = User.create
        expect(User.with_preference(:food, :wine, 'red')).to eq([user, user_2])
      end

      it 'includes admins who have not explicitly overriden the preference' do
        admin.preferences(:hobbies).set(crosswords: true) # the default value
        admin_2 = Admin.create
        expect(Admin.with_preference(:hobbies, :crosswords, true)).to eq([admin, admin_2])
      end
    end

    context 'missing preferences' do
      it 'fails gracefully when trying to set undefined pref' do
        expect {
          user.preferences(:hobbies).set(favorites: :tennis)
        }.to raise_error(ArgumentError, "definition for User at hobbies/favorites is not defined")
      end

      it 'fails gracefully when trying to set undefined category' do
        expect {
          user.preferences(:music).set(genre: :jazz)
        }.to raise_error(ArgumentError, "definition for User at music/genre is not defined")
      end
    end
  end
end