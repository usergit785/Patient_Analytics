{{ config(
    materialized='table'
) }}

with cleaned as (

    select
        -- Identifiers
        
        coalesce(nullif(trim(PROVIDER_ID), ''), 'NA') as PROVIDER_ID,
        coalesce(nullif(trim(ORGANIZATION_ID), ''), 'NA') as ORGANIZATION_ID,

        -- provider details   
        coalesce(
CONCAT(
    REGEXP_SUBSTR(provider_name, '[A-Za-z]+'),
    ' ',
    REGEXP_SUBSTR(provider_name, '[A-Za-z]+', 1, 2)
  )
,'NA') AS provider_name,

        coalesce(nullif(trim(GENDER), ''), 'NA') as GENDER,
        coalesce(nullif(trim(SPECIALTY), ''), 'NA') as SPECIALTY,
        coalesce(nullif(trim(ADDRESS), ''), 'NA') as ADDRESS,
        coalesce(nullif(trim(CITY), ''), 'NA') as CITY,
        coalesce(nullif(trim(STATE), ''), 'NA') as STATE,
        coalesce(nullif(trim(ZIP), ''), 'NA') as ZIP,
        coalesce(try_cast(LATITUDE as float), 0.0) as LATITUDE,
        coalesce(try_cast(LONGITUDE as float), 0.0) as LONGITUDE,
        coalesce(try_cast(ENCOUNTER_COUNT as int), 0) as ENCOUNTER_COUNT,
        coalesce(try_cast(PROCEDURE_COUNT as int), 0) as PROCEDURE_COUNT


    from {{ ref('Providers') }}
),

--select * from cleansed_providers
deduplicated as (
    select distinct * from cleaned
)

select * from deduplicated