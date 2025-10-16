{{ config(materialized='table') }}

with unified_patients as (

    -- CSV patients
    select
        id as patient_id,
        last as last_name,
        first as first_name,
        null as middle_name,
        to_date(birthdate) as birthdate,
        to_date(DEATHDATE) as deathdate,
        gender,
        race,
        null as PHONE_HOME,
        null as PHONE_BUSINESS,
        null as LANGUAGE,
        marital as marital_status,
        null as RELIGION,
        null as ACCOUNT_NUMBER,
        drivers as driver_license,
        ssn,
        null as NATIONALITY,
        passport,
        prefix,
        suffix,
        null as ETHNICITY_CODE,
        ethnicity,
        birthplace,
        maiden,
        address,
        city,
        state, 
        null as POSTAL_CODE,
        null as RACE_CODE,
        county,
        FIPS,
        ZIP,
        LAT,
        LON,
        HEALTHCARE_EXPENSES,
        HEALTHCARE_COVERAGE,
        INCOME
    from {{ source('patient_analytics_csv', 'patients') }}

    union all

    -- HL7 patients
    select
        patient_id,
        last_name,
        first_name,
        middle_name,
        to_date(date_of_birth) as birthdate,
        to_date(DEATH_DATETIME) as deathdate,
        gender,
        race,
        PHONE_HOME,
        PHONE_BUSINESS,
        LANGUAGE,
        marital_status,
        RELIGION,
        ACCOUNT_NUMBER,
        null as driver_license,
        ssn,
        NATIONALITY,
        null as passport,
        null as prefix,
        null as suffix,
        null as ETHNICITY_CODE,
        null as ethnicity,
        null as birthplace,
        mother_maiden_name as maiden,
        address,
        null as city,
        null as state, 
        null as POSTAL_CODE,
        null as RACE_CODE,
        null as county,
        null as FIPS,
        null as ZIP,
        null as LAT,
        null as LON,
        null as HEALTHCARE_EXPENSES,
        null as HEALTHCARE_COVERAGE,
        null as INCOME
    from {{ source('patient_analytics_src', 'patients') }}

    union all

    -- CCDA patients
    select
        patient_id,
        patient_last_name as last_name,
        patient_first_name as first_name,
        null as middle_name,
        to_date(to_timestamp(birth_date,'YYYYMMDDHH24MISS')) as birthdate,
        null as deathdate,
        gender,
        race_display as race,
        null as PHONE_HOME,
        null as PHONE_BUSINESS,
        null as LANGUAGE,
        null as marital_status,
        null as RELIGION,
        null as ACCOUNT_NUMBER,
        null as driver_license,
        null as ssn,
        null as NATIONALITY,
        null as passport,
        null as prefix,
        null as suffix,
        ETHNICITY_CODE,
        ethnicity_display as ethnicity,
        null as birthplace,
        null as maiden,
        address_line as address,
        city,
        state,
        POSTAL_CODE,
        RACE_CODE,
        null as county,
        null as FIPS,
        null as ZIP,
        null as LAT,
        null as LON,
        null as HEALTHCARE_EXPENSES,
        null as HEALTHCARE_COVERAGE,
        null as INCOME
    from {{ source('patient_analytics_ccda', 'patient_demographics') }}

)

select * from unified_patients