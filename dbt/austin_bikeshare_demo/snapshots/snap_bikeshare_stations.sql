{% snapshot snap_bikeshare_stations %}

{{
  config(
    target_schema='snapshots',
    unique_key='station_id',
    strategy='timestamp',
    updated_at='modified_date',
    invalidate_hard_deletes=True
  )
}}

SELECT
  station_id,
  name AS station_name,
  status,
  address,
  number_of_docks,
  council_district,
  modified_date

FROM {{ source('austin_bikeshare', 'bikeshare_stations') }}

{% endsnapshot %}