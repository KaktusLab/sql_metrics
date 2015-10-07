# SqlMetrics

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/sql_metrics`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sql_metrics'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sql_metrics

## Usage

### Setup database and table

You need to create the following table in your postgres or redshift database:

    CREATE TABLE events (created_at timestamp, name varchar(200), properties json);

Now you need to tell the gem how to connect to your db.

    SqlMetrics.configure do |config|
      config.host = '127.0.0.1'
      config.db_name = 'my_metrics_db'
      config.user = 'my_postgres_user'
      config.password = 'my_password'
    end

### Track a event

A simple event can look like this:

    SqlMetrics.track('event_name', {:a_property => 'hello world', :another_property => 'hello user'})

You can also pass a rails request object from a controller:

    SqlMetrics.track('event_name', {:a_property => 'hello world', :another_property => 'hello user'}, request)

This will automatically fetch properties like the user agent, client ip, requested url, etc

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/KaktusLab/sql_metrics. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

