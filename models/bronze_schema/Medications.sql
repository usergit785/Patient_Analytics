{{ config(
    materialized='table'
) }}

with unified_medications as (

    -- 💊 1️⃣ CSV Medications
    select
        
        cast(PATIENT as varchar) as PATIENT_ID,
        cast(ENCOUNTER as varchar) as ENCOUNTER_ID,
        cast(CODE as varchar) as MEDICATION_CODE,
        cast(DESCRIPTION as varchar) as MEDICATION_DESCRIPTION,
        to_date(to_timestamp_tz("START",'YYYY-MM-DD"T"HH24:MI:SS"Z"')) as MEDICATION_START_DATE,
        to_date(to_timestamp_tz("STOP",'YYYY-MM-DD"T"HH24:MI:SS"Z"')) as MEDICATION_END_DATE,
        cast(null as varchar) as ORDER_CONTROL,
        cast(null as varchar) as PRIORITY,
        cast(null as varchar) as REQUESTED_DATETIME,
        cast(null as varchar) as ORDERING_PROVIDER,
        cast(null as varchar) as ORDER_STATUS,
        cast(null as varchar) as SOURCE_FOLDER,
        cast(null as timestamp_ntz) as PROCESSED_AT,
        'CSV' as SOURCE_SYSTEM
    from {{ source('csv', 'medications') }}

    union all

    -- 💊 2️⃣ CCDA Medications
    select
        
        cast(PATIENT_ID as varchar) as PATIENT_ID,
        cast(null as varchar) as ENCOUNTER_ID,
        cast(MEDICATION_CODE as varchar) as MEDICATION_CODE,
        cast(MEDICATION_DISPLAY as varchar) as MEDICATION_DESCRIPTION,
        to_date(to_timestamp(START_DATE,'YYYYMMDDHH24MISS')) as MEDICATION_START_DATE,
        to_date(to_timestamp(END_DATE,'YYYYMMDDHH24MISS')) as MEDICATION_END_DATE,
        cast(null as varchar) as ORDER_CONTROL,
        cast(null as varchar) as PRIORITY,
        cast(null as varchar) as REQUESTED_DATETIME,
        cast(null as varchar) as ORDERING_PROVIDER,
        cast(null as varchar) as ORDER_STATUS,
        cast(null as varchar) as SOURCE_FOLDER,
        cast(CREATED_AT as timestamp_ntz) as PROCESSED_AT,
        'CCDA' as SOURCE_SYSTEM
    from {{ source('ccda', 'medications') }}

    union all

    -- 💊 3️⃣ HL7 Orders (Medications)
    select
        
        cast(PATIENT_ID as varchar) as PATIENT_ID,
        cast(null as varchar) as ENCOUNTER_ID,
        -- ❗️Temporarily setting these to NULL until we confirm HL7 columns
        cast(null as varchar) as MEDICATION_CODE,
        cast(null as varchar) as MEDICATION_DESCRIPTION,
        to_date(observation_datetime) as MEDICATION_START_DATE,
        cast(null as varchar) as MEDICATION_END_DATE,
        cast(ORDER_CONTROL as varchar) as ORDER_CONTROL,
        cast(PRIORITY as varchar) as PRIORITY,
        cast(REQUESTED_DATETIME as varchar) as REQUESTED_DATETIME,
        cast(ORDERING_PROVIDER as varchar) as ORDERING_PROVIDER,
        cast(ORDER_STATUS as varchar) as ORDER_STATUS,
        cast(SOURCE_FOLDER as varchar) as SOURCE_FOLDER,
        cast(PROCESSED_AT as timestamp_ntz) as PROCESSED_AT,
        'HL7' as SOURCE_SYSTEM
    from {{ source('hl7', 'orders') }}
)

select * from unified_medications
