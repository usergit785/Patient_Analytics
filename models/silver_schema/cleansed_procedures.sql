{{ config(
    materialized='table'
) }}

with cleaned as (

    select
        -- Identifiers
        coalesce(nullif(trim(PATIENT_ID), ''), 'NA') as PATIENT_ID,
        coalesce(nullif(trim(ENCOUNTER_ID), ''), 'NA') as ENCOUNTER_ID,

        -- Procedure details
        coalesce(nullif(trim(PROCEDURE_CODE), ''), 'NA') as PROCEDURE_CODE,
        coalesce(nullif(trim(PROCEDURE_DESCRIPTION), ''), 'NA') as PROCEDURE_DESCRIPTION,

        -- Procedure timing (date only)
        coalesce(to_char(PROCEDURE_START_DATETIME), 'NA') as PROCEDURE_START_DATE,
        coalesce(to_char(PROCEDURE_END_DATETIME), 'NA') as PROCEDURE_END_DATE,

        -- Cost and reason
        coalesce(nullif(trim(BASE_COST), ''), 'NA') as BASE_COST,
        coalesce(nullif(trim(REASON_CODE), ''), 'NA') as REASON_CODE,
        coalesce(nullif(trim(REASON_DESCRIPTION), ''), 'NA') as REASON_DESCRIPTION

    from {{ ref('Procedures') }}
),

--select * from cleansed_observations
deduplicated as (
    select distinct * from cleaned
)


select * from deduplicated
