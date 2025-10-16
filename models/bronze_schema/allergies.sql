{{ config(
    materialized='table'
) }}

with unified_allergies as (

    -- CSV Source
    select
        null as message_id,
        to_date("START") as start_date,
        PATIENT,
        null as entry_index,
        ENCOUNTER,
        cast(CODE as varchar(20)) as code,
        SYSTEM,
        DESCRIPTION,
        TYPE,
        null as allergy_type1,
        CATEGORY,
        REACTION1,
        DESCRIPTION1,
        null as allergen,
        SEVERITY1,
        REACTION2,
        DESCRIPTION2,
        SEVERITY2,
        null as severity,
        null as REACTION_CODE,
        null as REACTION_DISPLAY,
        null as STATUS,
        null as CREATED_AT,
        null as IDENTIFICATION_DATE,
        null as SOURCE_FOLDER,
        null as PROCESSED_AT,
        'CSV' as source_system
    from {{ source('patient_analytics_csv','allergies') }}

    union all

    -- HL7 Source
    select 
        message_id,
        null as start_date,
        PATIENT_ID,
        null as entry_index,
        null as ENCOUNTER,
        null as code,
        null as SYSTEM,
        null as description,
        null as TYPE,
        null as allergy_type1,
        allergy_type,
        null as REACTION1,
        null as DESCRIPTION1,
        allergen,
        null as severity1,
        null as REACTION2,
        null as DESCRIPTION2,
        null as SEVERITY2,
        severity,
        REACTION_CODE,
        null as REACTION_DISPLAY,
        null as STATUS,
        null as CREATED_AT,
        to_date(IDENTIFICATION_DATE, 'YYYY-MM-DD') as IDENTIFICATION_DATE,
        SOURCE_FOLDER,
        PROCESSED_AT,
        'HL7' as source_system
    from {{ source('patient_analytics_src','allergies') }}

    union all

    -- CCDA Source
    select
        null as message_id,
        null as start_date, 
        patient_id,
        ENTRY_INDEX,
        null as ENCOUNTER,
        ALLERGEN_CODE as code,
        null as SYSTEM,
        ALLERGEN_DISPLAY as description,
        null as TYPE,
        null as allergy_type1,
        null as CATEGORY,
        null as REACTION1,
        null as DESCRIPTION1,
        null as allergen,
        null as severity1,
        null as REACTION2,
        null as DESCRIPTION2,
        null as SEVERITY2,
        null as severity,
        REACTION_CODE,
        REACTION_DISPLAY,
        STATUS,
        CREATED_AT,
        null as IDENTIFICATION_DATE,
        null as SOURCE_FOLDER,
        null as PROCESSED_AT,
        'CCDA' as source_system
    from {{ source("patient_analytics_ccda",'allergies') }}

)

select * from unified_allergies