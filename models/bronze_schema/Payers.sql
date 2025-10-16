{{ config(
    materialized='table'
) }}

with unified_payers as (

    -- 🏦 CSV Payers
    select
        cast(ID as varchar) as PAYER_ID,                -- unique payer identifier
        cast(NAME as varchar) as PAYER_NAME,            -- payer / insurance name
        cast(OWNERSHIP as varchar) as PAYER_OWNERSHIP,  -- public/private/employer
        cast(null as varchar) as PAYER_TYPE,            -- placeholder for missing TYPE
        cast(PHONE as varchar) as CONTACT_NUMBER,       -- contact number (if exists)
        cast(ADDRESS as varchar) as ADDRESS,           -- street address (if exists)
        cast(CITY as varchar) as CITY                 -- city (if exists)
                             -- lineage marker
    from {{ source('patient_analytics_csv', 'payers') }}

)

select * from unified_payers

