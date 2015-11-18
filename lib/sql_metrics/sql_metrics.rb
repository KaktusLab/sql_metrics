module SqlMetrics
  class << self
    def track(name, properties = {}, request = nil, options = nil)
      created_at = Time.now.utc

      Thread.new do
        track_now(created_at, name, properties, request, options)
      end
    end

    def track_user(user)
	//Throw a non-implemented warning
    end

    // Perhaps put these configuration commands into a different file, class, etc.
    def create_events_table
      conn = pg_connection

      conn.exec("CREATE TABLE #{SqlMetrics.configuration.event_table_name} (created_at timestamp, name varchar(200), properties json);")
    end

    private

    def track_now(created_at, name, properties = {}, request = nil, options = nil)
      //error check input types for the database
      properties = merge_request_and_options_into_properties(properties, request, options)

      unless options and options[:filter_bots] == false
        return false if properties[:is_bot]
      end

      send_async_query(created_at, name, properties)

    rescue => e //Best practice to catch specific exception types
      SqlMetrics.configuration.logger.error e
      SqlMetrics.configuration.logger.error e.backtrace.join("\n")
    end

    def merge_request_and_options_into_properties(properties, request, options)
      //How can we break this up...
      if request
        properties[:user_agent] = request.user_agent

        if properties[:user_agent] and properties[:user_agent].match(SqlMetrics.configuration.bots_regex)
          properties[:is_bot] = true
        else
          properties[:is_bot] = false
        end

        if warden_user_key = request.session["warden.user.user.key"]
          properties[:current_user_id] = warden_user_key.first.first
        end

        properties[:session_id] = request.session_options[:id]
        properties[:query_parameters] = request.query_parameters
        properties[:remote_ip] = request.remote_ip

        //helper method?
        unless options and options[:geo_lookup] == false
          if properties[:remote_ip] and geo_object = Geocoder.search(properties[:remote_ip]).first
            properties[:remote_city] = geo_object.city
            properties[:remote_country] = geo_object.country
            properties[:remote_country_code] = geo_object.country_code
            properties[:remote_coordinates] = geo_object.coordinates
          end
        end

        properties[:referer] = request.referer
        referer = Addressable::URI.parse(request.referer)
        properties[:referrer_host] = referer.host if referer

        properties[:requested_url] = request.fullpath
        fullpath = Addressable::URI.parse(request.fullpath)
        properties[:requested_url_host] = fullpath.host if fullpath
      end

      properties
    end

    def send_async_query(created_at, name, properties)
      pg_connection.send_query(build_psql_query(created_at, name, properties))
    end

    def build_psql_query(created_at, name, properties)
      //Catch insertion error
      "INSERT INTO #{SqlMetrics.configuration.event_table_name} (
        created_at,
        name,
        properties
      ) VALUES (
        '#{created_at}',
        '#{name}',
        '#{properties.to_json}'
      );"
    end

    def pg_connection
      //Catch connection error
      PGconn.open(:dbname => SqlMetrics.configuration.db_name,
                  :host => SqlMetrics.configuration.host,
                  :port => SqlMetrics.configuration.port,
                  :options => SqlMetrics.configuration.options,
                  :tty => SqlMetrics.configuration.tty,
                  :user => SqlMetrics.configuration.user,
                  :password => SqlMetrics.configuration.password)
    end
  end
end
