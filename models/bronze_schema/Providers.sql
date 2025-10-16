{{ config(
    materialized='table'
) }}

with unified_providers as (

    -- 👨‍⚕️ CSV Providers
    select
        cast(ID as varchar) as PROVIDER_ID,                 -- unique provider id
        cast(ORGANIZATION as varchar) as ORGANIZATION_ID,   -- FK to organization
        cast(NAME as varchar) as PROVIDER_NAME,             -- provider full name
        cast(GENDER as varchar) as GENDER,                  -- gender
        cast(SPECIALITY as varchar) as SPECIALTY,           -- specialty (spelling normalized)
        cast(ADDRESS as varchar) as ADDRESS,                -- address
        cast(CITY as varchar) as CITY,                      -- city
        cast(STATE as varchar) as STATE,                    -- state
        cast(ZIP as varchar) as ZIP,                        -- postal code
        try_cast(LAT as float) as LATITUDE,                 -- latitude (geo)
        try_cast(LON as float) as LONGITUDE,                -- longitude (geo)
        try_cast(ENCOUNTERS as int) as ENCOUNTER_COUNT,     -- number of encounters
        try_cast(PROCEDURES as int) as PROCEDURE_COUNT                          -- lineage marker
    from {{ source('patient_analytics_csv', 'providers') }}

)


select * from unified_providers
