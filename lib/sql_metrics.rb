require "sql_metrics/version"

module SqlMetrics
  class Configuration
    require 'pg'

    attr_accessor :host, :port, :options, :tty, :db_name, :user, :password, :database_schema, :event_table_name

    def initialize
      self.host = nil
      self.port = 5432
      self.options = nil
      self.tty = nil
      self.db_name = nil
      self.user = nil
      self.password = nil
      self.database_schema = 'public'
      self.event_table_name = 'events'
      self.bots_regex = /Googlebot|Pingdom|bing|Yahoo|Amazon|Twitter|Yandex|majestic12/i
    end
  end

  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||=  Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end

  def initialize

  end

  def self.track(name, properties = {}, request = nil, options = nil)
    if request
      properties[:user_agent] = request.user_agent
      properties[:session_id] = request.session_options[:id]
      properties[:remote_ip] = request.remote_ip

      properties[:referrer] = request.referer
      referer = Addressable::URI.parse(request.referer)
      properties[:referrer_host] = referer.host if referer

      properties[:requested_url] = request.fullpath
      fullpath = Addressable::URI.parse(request.fullpath)
      properties[:requested_url_host] = fullpath.host if fullpath
    end

    SqlMetrics.delay.track_now(Time.now.utc, name, properties, options)
  end

  def self.track_now(created_at, name, properties, options)
    unless options[:filter_bots] == false
      return if properties[:user_agent] and properties[:user_agent].match(SqlMetrics.configuration.bots_regex)
    end

    conn = pg_connection

    conn.exec("INSERT INTO #{SqlMetrics.configuration.event_table_name} (
        created_at,
        name,
        properties
      ) VALUES (
        '#{created_at}',
        '#{name}',
        '#{properties.to_json}'
      );")

    puts 'test'
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
  end

  def self.pg_connection
    PGconn.open(:dbname => SqlMetrics.configuration.db_name,
                :host => SqlMetrics.configuration.host,
                :port => SqlMetrics.configuration.port,
                :options => SqlMetrics.configuration.options,
                :tty => SqlMetrics.configuration.tty,
                :user => SqlMetrics.configuration.user,
                :password => SqlMetrics.configuration.password)
  end
end
