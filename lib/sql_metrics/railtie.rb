require 'sql_metrics'
require 'rails'

module SqlMetrics
  class Railtie < Rails::Railtie
    rake_tasks do
      import '../sql_metrics/lib/tasks/sql_metrics.rake'
    end
  end
end