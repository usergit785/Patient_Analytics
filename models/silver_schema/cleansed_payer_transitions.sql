{{ config(
    materialized='table'
) }}

with cleaned as (

    select
        -- Identifiers
        coalesce(nullif(trim(PATIENT_ID), ''), 'NA') as PATIENT_ID,
        coalesce(nullif(trim(MEMBER_ID), ''), 'NA') as MEMBER_ID,
        coalesce(nullif(trim(PAYER_ID), ''), 'NA') as PAYER_ID,
        coalesce(nullif(trim(SECONDARY_PAYER_ID), ''), 'NA') as SECONDARY_PAYER_ID,

        -- Plan details
        coalesce(nullif(trim(PLAN_OWNERSHIP), ''), 'NA') as PLAN_OWNERSHIP,
        coalesce(nullif(trim(OWNER_NAME), ''), 'NA') as OWNER_NAME,

        -- Coverage dates
        coalesce(to_char(COVERAGE_START_DATE), 'NA') as COVERAGE_START_DATE,
        coalesce(to_char(COVERAGE_END_DATE), 'NA') as COVERAGE_END_DATE

    from {{ ref('Payer_transitions') }}
),

--select * from cleansed_observations
deduplicated as (
    select distinct * from cleaned
)


select * from deduplicated


