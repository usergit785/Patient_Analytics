{{ config(
    materialized='table'
) }}

with cleaned as (

    select
        -- Identifiers
        coalesce(nullif(trim(PATIENT_ID), ''), 'NA') as PATIENT_ID,
        coalesce(nullif(trim(ENCOUNTER_ID), ''), 'NA') as ENCOUNTER_ID,

        -- Supply core attributes
        coalesce(nullif(trim(SUPPLY_CODE), ''), 'NA') as SUPPLY_CODE,
        coalesce(nullif(trim(SUPPLY_DESCRIPTION), ''), 'NA') as SUPPLY_DESCRIPTION,
        supply_date as SUPPLY_DATE,
        -- Supply quantity (if exists)
        coalesce(nullif(trim(SUPPLY_QUANTITY), ''), 'NA') as SUPPLY_QUANTITY

    from {{ ref('Supplies') }}
),

--select * from cleansed_observations
deduplicated as (
    select distinct * from cleaned
)


select * from deduplicated
