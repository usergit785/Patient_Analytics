{{ config(
    materialized='table'
) }}

with unified_payer_transitions as (

    select
        cast(PATIENT as varchar) as PATIENT_ID,                 -- patient reference
        cast(MEMBERID as varchar) as MEMBER_ID,                 -- membership / policy id
        cast(PAYER as varchar) as PAYER_ID,                     -- primary payer id
        try_cast(SECONDARY_PAYER as varchar) as SECONDARY_PAYER_ID,  -- optional secondary payer
        try_cast(PLAN_OWNERSHIP as varchar) as PLAN_OWNERSHIP,       -- plan ownership type
        try_cast(OWNER_NAME as varchar) as OWNER_NAME,               -- policy holder name
        to_date(to_timestamp_tz(START_DATE,'YYYY-MM-DD"T"HH24:MI:SS"Z"')) as COVERAGE_START_DATE,     -- coverage start
        to_date(to_timestamp_tz(END_DATE,'YYYY-MM-DD"T"HH24:MI:SS"Z"')) as COVERAGE_END_DATE   
                
                                                                  -- lineage marker
    from {{ source('patient_analytics_csv', 'payer_transitions') }}

)

select * from unified_payer_transitions
