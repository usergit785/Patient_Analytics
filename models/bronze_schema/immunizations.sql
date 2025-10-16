{{ config(
    materialized='table'
) }}

with unified_immunizations as (

    -- CSV patients
    select
        to_date(to_timestamp_tz(Date,'YYYY-MM-DD"T"HH24:MI:SS"Z"'))  as administration_date,
        patient as patient_id,
        encounter,
        code,
        description,
        null as vaccine_display,
        base_cost,
        'CSV' as source_system
    from {{ source('patient_analytics_csv', 'immunizations') }}

    union all

    -- CCDA patients
    select
        to_date(to_timestamp(ADMINISTRATION_DATE,'YYYYMMDDHH24MISS')) as administration_date,
        PATIENT_ID as patient_id,
        null as encounter,
        null as code,
        null as description,
        vaccine_display,
        null as base_cost,
        'CCDA' as source_system
    from {{ source('patient_analytics_ccda', 'immunizations') }}

)

select * from unified_immunizations