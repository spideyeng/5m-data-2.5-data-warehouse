SELECT
  -- Primary key
  trip_id,
  
  -- Trip attributes
  subscriber_type,
  duration_minutes,
  
  -- Start location
  start_station_id,
  start_station_name,
  
  -- End location
  end_station_id,
  end_station_name,
  
  -- Timestamps
  start_time,
  
  -- Derived date/time fields
  EXTRACT(DATE FROM start_time) AS trip_date,
  EXTRACT(HOUR FROM start_time) AS start_hour,
  EXTRACT(DAYOFWEEK FROM start_time) AS day_of_week

FROM {{ source('austin_bikeshare', 'bikeshare_trips') }}