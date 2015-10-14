require "sql_metrics/version"

module SqlMetrics
  class Configuration
    require 'pg'
    require 'logger'
    require 'json'
    require 'geocoder'

    attr_accessor :host, :port, :options, :tty, :db_name, :user, :password, :database_schema, :event_table_name,
                  :bots_regex, :logger

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

      self.logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    end
  end

  class << self
    attr_accessor :configuration

    def merge_request_and_options_into_properties(properties, request, options)
      if request
        properties[:user_agent] = request.user_agent
        properties[:session_id] = request.session_options[:id]
        properties[:remote_ip] = request.remote_ip

        unless options and options[:geo_lookup] == false
          if properties[:remote_ip] and geo_object = Geocoder.search(properties[:remote_ip]).first
            properties[:remote_city] = geo_object.city
            properties[:remote_country] = geo_object.country
            properties[:remote_country_code] = geo_object.country_code
            properties[:remote_coordinates] = geo_object.coordinates
          end
        end

        properties[:referrer] = request.referer
        referer = Addressable::URI.parse(request.referer)
        properties[:referrer_host] = referer.host if referer

        properties[:requested_url] = request.fullpath
        fullpath = Addressable::URI.parse(request.fullpath)
        properties[:requested_url_host] = fullpath.host if fullpath
      end

      properties
    end

    def send_async_query(name, properties)
      pg_connection.send_query(build_psql_query(name, properties))
    end

    def build_psql_query(name, properties)
      "INSERT INTO #{SqlMetrics.configuration.event_table_name} (
        created_at,
        name,
        properties
      ) VALUES (
        '#{Time.now.utc}',
        '#{name}',
        '#{properties.to_json}'
      );"
    end
  end

  def self.configuration
    @configuration ||=  Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end

  def self.track(name, properties = {}, request = nil, options = nil)
    properties = merge_request_and_options_into_properties(properties, request, options)

    unless options and options[:filter_bots] == false
      return false if properties[:user_agent] and properties[:user_agent].match(SqlMetrics.configuration.bots_regex)
    end

    send_async_query(name, properties)
  rescue => e
    SqlMetrics.configuration.logger.error e
    SqlMetrics.configuration.logger.error e.backtrace.join("\n")
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
