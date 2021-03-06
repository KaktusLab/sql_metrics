# SqlMetrics

A simple gem to track metric events in your own postgres or Amazon Redshift database.

[![Gem Version](https://badge.fury.io/rb/sql_metrics.svg)](https://badge.fury.io/rb/sql_metrics)

## Features

* Asynchronously stores events into Postgres or Amazon Redshift based db
* Filters commonly known bots by default
* Uses geoip gem to extract city/country from client ip's

## Todo

* Batch inserting events to db to improve performance under very high load
* Track Users (just because thats a common thing to do besides tracking raw events)
* Offer SQL based dashboard that allows to run custom queries and also render charts

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

Tell the gem how to connect to your db. So simply create a file called sql_metrics.rb into your config/libs folder with the config:

    SqlMetrics.configure do |config|
      config.host = '127.0.0.1'
      config.db_name = 'my_metrics_db'
      config.user = 'my_postgres_user'
      config.password = 'my_password'
    end

Then to create the required events table just run this rake task:

    rake sql_metrics:create_events_table

### Track a event

A simple event can look like this:

    SqlMetrics.track(
      'event_name',
      {
        :a_property => 'hello world',
        :another_property => 'hello user'
      }
    )

You can also pass a rails request object from a controller:

    SqlMetrics.track(
      'event_name',
      {
        :a_property => 'hello world',
        :another_property => 'hello user'
      },
      request
    )

The gem automatically filters bots for you using the user_agent property from the rails request object...you can disable this if you want:

    SqlMetrics.track(
      'event_name',
      {
        :a_property => 'hello world',
        :another_property => 'hello user'
      },
      request,
      {
        :filter_bots => false
      }
    )

The gem also automatically performs a geo lookup using the remote_ip property from the rails request object...you can disable this if you want:

    SqlMetrics.track(
      'event_name',
      {
        :a_property => 'hello world',
        :another_property => 'hello user'
      },
      request,
      {
        :geo_lookup => false
      }
    )

This will automatically fetch properties like the user agent, client ip, requested url, etc

## Additional Config parameters

### Change default DB Table name

    SqlMetrics.configure do |config|
      config.host = '127.0.0.1'
      config.db_name = 'my_metrics_db'
      config.user = 'my_postgres_user'
      config.password = 'my_password'

      config.event_table_name = 'my_custom_events_table'
    end

### Change default DB Schema

    SqlMetrics.configure do |config|
      config.host = '127.0.0.1'
      config.db_name = 'my_metrics_db'
      config.user = 'my_postgres_user'
      config.password = 'my_password'

      config.database_schema = 'my_custom_schema'
    end

### Change Bot regex filter

    SqlMetrics.configure do |config|
      config.host = '127.0.0.1'
      config.db_name = 'my_metrics_db'
      config.user = 'my_postgres_user'
      config.password = 'my_password'

      config.bots_regex = /Googlebot|Pingdom|bing|Yahoo|Amazon|Twitter|Yandex|majestic12/i
    end


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/KaktusLab/sql_metrics. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

