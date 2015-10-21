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

      self.bots_regex = /Googlebot|Pingdom|bing|Yahoo|Amazon|Twitter|Yandex|baidu|majestic12/i

      self.logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    end
  end
end