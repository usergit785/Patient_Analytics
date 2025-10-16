{{ config(
    materialized='table'
) }}

with cleaned as (

    select
        coalesce(nullif(trim(PATIENT_ID), ''), 'NA') as PATIENT_ID,
        coalesce(nullif(trim(ENCOUNTER_ID), ''), 'NA') as ENCOUNTER_ID,
        coalesce(nullif(trim(MEDICATION_CODE), ''), 'NA') as MEDICATION_CODE,
        coalesce(nullif(trim(MEDICATION_DESCRIPTION), ''), 'NA') as MEDICATION_DESCRIPTION,

        -- Convert only string columns to date
        MEDICATION_START_DATE,
        MEDICATION_END_DATE

    from {{ ref('Medications') }}

),

deduplicated as (

    select distinct * from cleaned

)

select * from deduplicated