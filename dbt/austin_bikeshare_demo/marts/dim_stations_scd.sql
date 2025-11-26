SELECT
  -- Surrogate key for this version
  dbt_scd_id AS station_version_id,
  
  -- Natural key
  station_id,
  
  -- Station attributes (as of this version)
  station_name,
  status,
  address,
  number_of_docks,
  council_district,
  
  -- SCD metadata
  dbt_valid_from,
  dbt_valid_to,
  dbt_updated_at,
  
  -- Convenience flags
  CASE 
    WHEN dbt_valid_to IS NULL THEN TRUE 
    ELSE FALSE 
  END AS is_current,
  
  -- Version number within each station
  ROW_NUMBER() OVER (
    PARTITION BY station_id 
    ORDER BY dbt_valid_from
  ) AS version_number

FROM {{ ref('snap_bikeshare_stations') }}