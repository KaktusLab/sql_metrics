namespace :sql_metrics do

  desc 'Insert the events table'
  task :create_events_table => :environment do
    SqlMetrics.create_events_table
  end

end
