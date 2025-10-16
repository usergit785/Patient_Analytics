{{ config(
    materialized='table'
) }}

with unified_observations as (

    select
        
        PATIENT_ID,
        SET_ID,
        VALUE_TYPE,
        OBSERVATION_ID as OBSERVATION_CODE,
        OBSERVATION_VALUE,
        UNITS,
        REFERENCE_RANGE,
        ABNORMAL_FLAGS,
        PROBABILITY,
        NATURE_OF_ABNORMAL_TEST,
        OBSERVATION_RESULT_STATUS as RESULT_STATUS,
        to_date(OBSERVATION_DATETIME) as OBSERVATION_DATE,
        OBSERVATION_METHOD
    from {{ source('hl7', 'observations') }}

    union all

    select
    
        PATIENT as PATIENT_ID,
        null as SET_ID,
        null as VALUE_TYPE,
        CODE as OBSERVATION_CODE,
        VALUE as OBSERVATION_VALUE,
        UNITS,
        null as REFERENCE_RANGE,
        null as ABNORMAL_FLAGS,
        null as PROBABILITY,
        CATEGORY as NATURE_OF_ABNORMAL_TEST,
        null as RESULT_STATUS,
        to_date(to_timestamp_tz(DATE,'YYYY-MM-DD"T"HH24:MI:SS"Z"')) as OBSERVATION_DATE,
        TYPE as OBSERVATION_METHOD
    from {{ source('csv', 'observations') }}
)

select * from unified_observations
