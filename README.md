# UserPreferences

An ActiveRecord backed user preference library that supports:
* Categories (currently non-optional)
* Binary and non-binary preferences
* Default values
* Value validation
* Retrieving users scoped by a particular preference

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'user_preferences'
```

And then execute:

```sh
$ bundle
```

Run the installation script:

```sh
$ rails g user_preferences:install
```

This will copy across the migration and add an empty preference definition file in config/

Finally, run the database migrations:

```sh
$ rake db:migrate
```

## Upgrading from 1.0.x to 1.1
```sh
$ rails g user_preferences:upgrade
```

This will copy across a migration to convert your prefs to allow polymorphism, giving you the ability to have independent preferences on multiple models.

Finally, run the database migrations:

```sh
$ rake db:migrate
```


## Add preferences to your model

Associate your models with preferences as follows:

```ruby
class User < ActiveRecord::Base
  has_preferences # preference definitions and defaults are stored in config/user_preferences.yml
end

class Admin < ActiveRecord::Base
  has_preferences # preference definitions and defaults are stored in config/admin_preferences.yml
end
```

This declaration takes no arguments, and simply sets up the correct associations
along with making available the rest of the methods described in the _API_ section
below.

## Defining preferences

Your preferences, along with their default values, are defined in ``config/#{class_name}_preferences.yml``. You define each of your
preferences within a category. This example definition for a binary preference implies that users receive emails notifications by default but not newsletters:
```yaml
emails:
  notifications: true
  newsletters: false
```

You can configure non-binary preferences. For example, if users could choose periodical notification digests, the configuration might look like this:

```yaml
emails:
  notifications:
    default: instant
    values:
      - off
      - instant
      - daily
      - weekly
  newsletters: false
```

You can add as many categories as you like:

```yaml
emails:
  notifications: true
  newsletters: false

beta_features:
  two_factor_authentication: false
  the_big_red_button: false
```

## API

### set
Similar to ActiveRecord, setting a preference returns true or false depending on whether or not it was successfully persisted:
```ruby
user.preferences(:emails).set(notifications: 'instant') # => true
user.preferences(:emails).set(notifications: 'some_typo') # => false
```

You can set multiple preferences at once:
```ruby
user.preferences(:emails).set(notifications: 'instant', newsletter: true) # => true
```

### get
A single preference:
```ruby
user.preferences(:emails).get(:notifications) # => 'instant'
```

### all
All preferences for a category:
```ruby
user.preferences(:emails).all # => { notifications: 'instant', newsletter: true }
```

### reload
Reload the preferences from the database; since something else might have changed the user's state.
```ruby
user.preferences(:emails).reload # => { notifications: 'instant', newsletter: true }
```

## Scoping users
```ruby
  newsletter_users = User.with_preference(:email, :newsletter, true) #=> an ActiveRecord::Relation
```
Note: this _will_ include users who have not overridden the default value if the value incidentally matches the default value.

## Other useful stuff

### Single preference definition
* Get your preference definition (as per your .yml) as a hash: ``User.definitions``
* Get the definition for a single preference:
```ruby

  preference = User.preferences[:emails, :notifications]
  preference.default # => 'instant'
  preference.binary? # => false
  preference.permitted_values # => ['off', 'instant', 'daily', 'weekly']
```
* Retrieve the default preference state with ``UserPreferences.defaults``. You can also scope to a category: ``UserPreferences.defaults(:emails)``

## Testing

```sh
$ rake test
```

## Contributing

1. Fork it ( http://github.com/mubi/user_preferences/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
