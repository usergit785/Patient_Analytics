{{ config(
    materialized='table'
) }}

with unified_conditions as (

    -- CSV patients
    select
        null as diagnosis_sequence,
        null as diagnosis_coding_method,
        to_date("START") as start_date,
        to_date("STOP") as end_date,
        patient,
        null as ENCOUNTER,
        cast(code as varchar(50)) as code,
        description,
        null as entry_index,
        null as observation_id,
        null as status
    from {{ source('patient_analytics_csv', 'conditions') }}

    union all

    -- HL7 patients
    select
        diagnosis_sequence,
        diagnosis_coding_method,
        to_date(to_timestamp_tz(diagnosis_type,'YYYYMMDDHH24MISS+TZHTZM')) as start_date,
        NULL AS end_date,
        patient_id,
        null as ENCOUNTER,
        cast(DIAGNOSIS_CODE as varchar(50)) as code,
        DIAGNOSIS_DESCRIPTION as description,
        null as entry_index,
        null as observation_id,
        null as status
    from {{ source('patient_analytics_src', 'diagnoses') }}

    union all

    -- CCDA patients
    select
        null as diagnosis_sequence,
        null as diagnosis_coding_method,
        to_date(to_timestamp(START_DATE,'YYYYMMDDHH24MISS')) as start_date,
        to_date(to_timestamp(END_DATE,'YYYYMMDDHH24MISS')) as end_date,
        PATIENT_ID as patient,
        null as encounter,
        cast(CONDITION_CODE as varchar(50)) as code,
        CONDITION_DISPLAY as description,
        entry_index,
        observation_id,
        status
    from {{ source('patient_analytics_ccda', 'problems') }}

)

select * from unified_conditions
