{{ config(
    materialized='table'
) }}

with unified_organization as (

    -- 🏥 CSV Organizations
    select
        cast(ID as varchar) as ORGANIZATION_ID,           -- unique organization identifier
        cast(NAME as varchar) as ORGANIZATION_NAME,       -- clinic or hospital name
        cast(ADDRESS as varchar) as ADDRESS,              -- street address
        cast(CITY as varchar) as CITY,                    -- city
        cast(STATE as varchar) as STATE,                  -- state abbreviation
        cast(ZIP as varchar) as ZIP,                      -- postal code
        cast(LAT as float) as LATITUDE,                   -- latitude (geo)
        cast(LON as float) as LONGITUDE,                  -- longitude (geo)
        cast(PHONE as varchar) as CONTACT_NUMBER,         -- contact phone
        cast(REVENUE as float) as REVENUE,                -- revenue metric
        cast(UTILIZATION as float) as UTILIZATION       -- utilization metric
                        
    from {{ source('csv', 'organizations') }}

)

select * from unified_organization
