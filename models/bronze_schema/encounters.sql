-- CSV Source
with unified_encounters as(
select  
    id,          
    PATIENT as patient_id,
    null as entry_index,
    null as visit_number,
    null as assigned_patient_location,
    null as admission_type,
    null as attending_doctor,
    null as referring_doctor,
    null as consulting_doctor,
    null as hospital_service,
    null as patient_class,
   
    ORGANIZATION,
    PROVIDER,
    PAYER,
    ENCOUNTERCLASS,
    to_date(to_timestamp_tz("START",'YYYY-MM-DD"T"HH24:MI:SS"Z"')) as start_date,
    to_date(to_timestamp_tz("STOP",'YYYY-MM-DD"T"HH24:MI:SS"Z"')) as end_date,
    
    code as encounter_code,
    DESCRIPTION,
    BASE_ENCOUNTER_COST,
    TOTAL_CLAIM_COST,
    PAYER_COVERAGE,
    REASONCODE,
    REASONDESCRIPTION
from {{ source('patient_analytics_csv', 'encounters') }}
    union all
 
    -- HL7 Source
    select  
        null as id ,
        patient_id,  
        null as entry_index,
        visit_number,
        assigned_patient_location,
        admission_type,
        attending_doctor,
        referring_doctor,
        consulting_doctor,
        hospital_service,
        patient_class,
        source_folder,
        
        null as PROVIDER,
        null as PAYER,
        patient_type as ENCOUNTERCLASS,  
        to_date(admission_datetime) as start_date,
        to_date(discharge_datetime) as end_date,
        
        null as encounter_code,
        null as DESCRIPTION,
        null as BASE_ENCOUNTER_COST,
        null as TOTAL_CLAIM_COST,
        null as PAYER_COVERAGE,
        null as REASONCODE,
        null as REASONDESCRIPTION
    from {{ source('patient_analytics_src', 'patient_visits') }}
    union all
        -- CCDA Source
    select      
        null as id ,
        patient_id,
        entry_index,
        null as visit_number,
        null as assigned_patient_location,
        null as admission_type,
        null as attending_doctor,
        null as referring_doctor,
        null as consulting_doctor,
        null as hospital_service,
        null as patient_class,
        null as ORGANIZATION,
        null as PROVIDER,
        null as PAYER,
        ENCOUNTER_DISPLAY as ENCOUNTERCLASS,  
        to_date(to_timestamp(start_time,'YYYYMMDDHH24MISS')) as start_date,
        to_date(to_timestamp(end_time,'YYYYMMDDHH24MISS')) as end_date,
        encounter_code,
        null as DESCRIPTION,
        null as BASE_ENCOUNTER_COST,
        null as TOTAL_CLAIM_COST,
        null as PAYER_COVERAGE,
        null as REASONCODE,
        null as REASONDESCRIPTION
    from {{ source('patient_analytics_ccda', 'encounters') }}
 


)
 
select * from unified_encounters
 