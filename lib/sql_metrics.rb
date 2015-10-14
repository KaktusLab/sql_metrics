require "sql_metrics/version"
require "sql_metrics/config"
require "sql_metrics/sql_metrics"

require "sql_metrics/railtie" if defined?(Rails)

module SqlMetrics
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||=  Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end
end
