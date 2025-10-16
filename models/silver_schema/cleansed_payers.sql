{{ config(
    materialized='table'
) }}

with cleaned as (

    select
        -- Identifiers
        coalesce(nullif(trim(PAYER_ID), ''), 'NA') as PAYER_ID,
        coalesce(nullif(trim(PAYER_NAME), ''), 'NA') as PAYER_NAME,

        -- Ownership and type
        coalesce(nullif(trim(PAYER_OWNERSHIP), ''), 'NA') as PAYER_OWNERSHIP

    from {{ ref('Payers') }}
),

--select * from cleansed_observations
deduplicated as (
    select distinct * from cleaned
)


select * from deduplicated
