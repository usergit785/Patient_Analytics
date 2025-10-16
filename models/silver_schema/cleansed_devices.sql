{{ config(
    materialized='table'
) }}

with cleaned as (

    select
        coalesce(nullif(trim(PATIENT_ID), ''), 'NA') as PATIENT_ID,
        coalesce(nullif(trim(ENCOUNTER_ID), ''), 'NA') as ENCOUNTER_ID,
        coalesce(nullif(trim(DEVICE_CODE), ''), 'NA') as DEVICE_CODE,
        coalesce(nullif(trim(DEVICE_DESCRIPTION), ''), 'NA') as DEVICE_DESCRIPTION,
        

        -- Parse DEVICE_UDI into separate columns
        coalesce(regexp_substr(DEVICE_UDI, '\\(01\\)(\\d{14})', 1, 1, 'e', 1), 'NA') as DEVICE_GTIN,
        coalesce(
            to_char(to_date(regexp_substr(DEVICE_UDI, '\\(11\\)(\\d{6})', 1, 1, 'e', 1), 'YYMMDD'), 'YYYY-MM-DD'),
            'NA'
        ) as MANUFACTURING_DATE,
        coalesce(
            to_char(to_date(regexp_substr(DEVICE_UDI, '\\(17\\)(\\d{6})', 1, 1, 'e', 1), 'YYMMDD'), 'YYYY-MM-DD'),
            'NA'
        ) as EXPIRY_DATE,
        coalesce(regexp_substr(DEVICE_UDI, '\\(10\\)([^\\(]+)', 1, 1, 'e', 1), 'NA') as BATCH_NUMBER,
        coalesce(regexp_substr(DEVICE_UDI, '\\(21\\)([^\\(]+)', 1, 1, 'e', 1), 'NA') as SERIAL_NUMBER

    from {{ ref('Devices') }}

),

deduplicated as (
    select distinct * from cleaned
)

select * from deduplicated