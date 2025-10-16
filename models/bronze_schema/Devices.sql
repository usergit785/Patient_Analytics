with unified_devices as (
    select
        cast(PATIENT as varchar) as PATIENT_ID,                 -- patient identifier
        cast(ENCOUNTER as varchar) as ENCOUNTER_ID,             -- encounter id
        cast(CODE as varchar) as DEVICE_CODE,                   -- SNOMED/device code
        cast(DESCRIPTION as varchar) as DEVICE_DESCRIPTION,     -- human-readable device name
        cast(UDI as varchar) as DEVICE_UDI,                     -- unique device identifier
        to_date("START") as DEVICE_START_DATE,          -- start date/time of usage
        to_date("STOP") as DEVICE_END_DATE            -- stop date/time of usage
                                      
    from {{ source('patient_analytics_csv', 'devices') }}

)

select * from unified_devices
