SELECT
  -- Trip identifiers
  t.trip_id,
  t.trip_date,
  t.start_time,
  t.start_hour,
  t.day_of_week,
  
  -- Trip attributes
  t.subscriber_type,
  t.duration_minutes,
  
  -- Start station (current identifiers)
  t.start_station_id,
  t.start_station_name,
  
  -- Station attributes AS OF trip date
  s.status AS start_station_status_at_trip,
  s.number_of_docks AS start_station_docks_at_trip,
  s.council_district AS start_station_district_at_trip,
  s.address AS start_station_address_at_trip,
  s.version_number AS start_station_version,
  
  -- End station
  t.end_station_id,
  t.end_station_name

FROM {{ ref('stg_bikeshare_trips') }} t

INNER JOIN {{ ref('dim_stations_scd') }} s
  ON t.start_station_id = s.station_id
  AND t.trip_date >= DATE(s.dbt_valid_from)
  AND t.trip_date < COALESCE(DATE(s.dbt_valid_to), DATE('9999-12-31'))