{{ config(
    materialized='table'
) }}

with unified_procedures as (

    -- 🩺 CSV Procedures
    select
                                                                 -- placeholder for HL7 alignment
        cast(PATIENT as varchar) as PATIENT_ID,                  -- patient reference
        cast(ENCOUNTER as varchar) as ENCOUNTER_ID,              -- encounter reference
        cast(CODE as varchar) as PROCEDURE_CODE,                 -- SNOMED / CPT / LOINC code
        cast(DESCRIPTION as varchar) as PROCEDURE_DESCRIPTION,   -- procedure name
        to_date(to_timestamp_tz("START",'YYYY-MM-DD"T"HH24:MI:SS"Z"')) as PROCEDURE_START_DATETIME,    -- ✅ quoted reserved keyword
        to_date(to_timestamp_tz(STOP,'YYYY-MM-DD"T"HH24:MI:SS"Z"')) as PROCEDURE_END_DATETIME,         -- end time
        try_cast(BASE_COST as float) as BASE_COST,               -- base cost
        cast(REASONCODE as varchar) as REASON_CODE,              -- linked diagnosis/reason code
        cast(REASONDESCRIPTION as varchar) as REASON_DESCRIPTION,-- reason description
        cast(null as varchar) as SOURCE_FOLDER,                  -- placeholder
        cast(null as timestamp_ntz) as PROCESSED_AT,             -- ingestion timestamp
        'CSV' as SOURCE_SYSTEM                                   -- lineage marker
    from {{ source('patient_analytics_csv', 'procedures') }}

)


select * from unified_procedures
