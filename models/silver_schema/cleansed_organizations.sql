{{ config(
    materialized='table'
) }}

with cleaned as (

    select
        -- Identifiers
        coalesce(nullif(trim(ORGANIZATION_ID), ''), 'NA') as ORGANIZATION_ID,
        coalesce(nullif(trim(ORGANIZATION_NAME), ''), 'NA') as ORGANIZATION_NAME,

        -- Location details
        coalesce(nullif(trim(ADDRESS), ''), 'NA') as ADDRESS,
        coalesce(nullif(trim(CITY), ''), 'NA') as CITY,
        coalesce(nullif(trim(ZIP), ''), 'NA') as ZIP,

        -- Geospatial coordinates
        coalesce(nullif(trim(LATITUDE), ''), 'NA') as LATITUDE,
        coalesce(nullif(trim(LONGITUDE), ''), 'NA') as LONGITUDE,

        -- Contact and metrics
        coalesce(nullif(trim(CONTACT_NUMBER), ''), 'NA') as CONTACT_NUMBER,
        coalesce(nullif(trim(UTILIZATION), ''), 'NA') as UTILIZATION
        

    from {{ ref('Organizations') }}
),

--select * from cleansed_observations
deduplicated as (
    select distinct * from cleaned
)


select * from deduplicated
