require 'spec_helper'

describe SqlMetrics do
  it 'has a version number' do
    expect(SqlMetrics::VERSION).not_to be nil
  end

  it 'configures lib' do
    SqlMetrics.configure do |config|
      config.host = '127.0.0.1'
      config.db_name = 'my_metrics_db'
      config.user = 'my_postgres_user'
      config.password = 'my_password'
    end

    expect(SqlMetrics.configuration.host).to eq('127.0.0.1')
    expect(SqlMetrics.configuration.db_name).to eq('my_metrics_db')
    expect(SqlMetrics.configuration.user).to eq('my_postgres_user')
    expect(SqlMetrics.configuration.password).to eq('my_password')
  end

  it 'tracks a simple event' do
    expect(SqlMetrics).to receive(:send_async_query).with('event_name', {}).and_return(true)

    SqlMetrics.track(
        'event_name'
    )
  end

  it 'tracks a simple event with properties' do
    expect(SqlMetrics).to receive(:send_async_query).with('event_name', {
                                                                          :a_property => 'hello world',
                                                                          :another_property => 'hello user'
                                                                      }).and_return(true)

    SqlMetrics.track(
        'event_name',
        {
            :a_property => 'hello world',
            :another_property => 'hello user'
        }
    )
  end

  it 'filters bots' do
    expect(SqlMetrics).to receive(:track).with('event_name', {:user_agent => 'Googlebot'}).and_return(false)

    SqlMetrics.track(
        'event_name',
        {
            :user_agent => 'Googlebot'
        }
    )
  end

  it 'filters bots with option true' do
    expect(SqlMetrics).to receive(:track).with('event_name', {:user_agent => 'Googlebot'}, nil, {:filter_bots => true}).and_return(true)

    SqlMetrics.track(
        'event_name',
        {
            :user_agent => 'Googlebot'
        },
        nil,
        {
            :filter_bots => true
        }
    )
  end

  it 'does not filters bots' do
    expect(SqlMetrics).to receive(:track).with('event_name', {:user_agent => 'Googlebot'}, nil, {:filter_bots => false}).and_return(true)

    SqlMetrics.track(
        'event_name',
        {
            :user_agent => 'Googlebot'
        },
        nil,
        {
            :filter_bots => false
        }
    )
  end

  it 'filters custom bots' do
    SqlMetrics.configure do |config|
      config.bots_regex = /mybot/i
    end

    expect(SqlMetrics).to receive(:track).with('event_name', {:user_agent => 'mybot'}).and_return(false)

    SqlMetrics.track(
        'event_name',
        {
            :user_agent => 'mybot'
        }
    )
  end
end