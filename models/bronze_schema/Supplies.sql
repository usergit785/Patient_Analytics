{{ config(
    materialized='table'
) }}

with unified_supplies as (

    -- 📦 CSV Supplies
    select
                            -- no HL7/CCDA context
        cast(PATIENT as varchar) as PATIENT_ID,                  -- patient reference
        cast(ENCOUNTER as varchar) as ENCOUNTER_ID,              -- encounter reference
        cast(CODE as varchar) as SUPPLY_CODE,                    -- SNOMED or custom code
        cast(DESCRIPTION as varchar) as SUPPLY_DESCRIPTION,      -- item name
        to_date(DATE) as SUPPLY_DATE,                    -- date of issue
        cast(QUANTITY as number) as SUPPLY_QUANTITY,             -- number of units
        cast(null as varchar) as SOURCE_FOLDER               -- placeholder
                                      -- lineage marker
    from {{ source('csv', 'supplies') }}

)

select * from unified_supplies
