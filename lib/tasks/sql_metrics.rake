namespace :sql_metrics do

  desc 'Insert the events table'
  task :create_events_table => :environment do
    begin
      SqlMetrics.create_events_table
      puts "Succesfully inserted #{SqlMetrics.configuration.event_table_name} table!"
    rescue => e
      puts e
    end
  end

end
