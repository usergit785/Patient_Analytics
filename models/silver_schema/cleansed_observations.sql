{{ config(
    materialized='table'
) }}

with cleansed_observations as (

    select
        coalesce(cast(PATIENT_ID as varchar), 'NA') as PATIENT_ID,

        -- 🧩 VALUE_TYPE → take characters after caret (^)
        coalesce(
            trim(split_part(VALUE_TYPE, '^', 2)),
            'NA'
        ) as VALUE_TYPE,

        -- 🧩 OBSERVATION_CODE → take characters before caret (^)
        coalesce(
            upper(trim(split_part(OBSERVATION_CODE, '^', 1))),
            'NA'
        ) as OBSERVATION_CODE,

        -- 🧩 Observation value (numeric cleaning)
        coalesce(cast(nullif(trim(OBSERVATION_VALUE), '') as varchar), 'NA') as OBSERVATION_VALUE,

        -- Units cleanup
        coalesce(upper(trim(UNITS)), 'NA') as UNITS,

        -- Reference range cleanup (Low and High)
        coalesce(trim(split_part(REFERENCE_RANGE, '-', 1)), 'NA') as REF_RANGE_LOW,
        case
            when trim(split_part(REFERENCE_RANGE, '-', 2)) = '' then 'NA'
            else trim(split_part(REFERENCE_RANGE, '-', 2))
        end as REF_RANGE_HIGH,

        -- Abnormal flag normalization
        coalesce(
            case 
                when upper(trim(ABNORMAL_FLAGS)) in ('H', 'HIGH') then 'HIGH'
                when upper(trim(ABNORMAL_FLAGS)) in ('L', 'LOW') then 'LOW'
                when upper(trim(ABNORMAL_FLAGS)) in ('N', 'NORMAL') then 'NORMAL'
                else upper(trim(ABNORMAL_FLAGS))
            end,
            'NA'
        ) as ABNORMAL_FLAG,

        -- Result status cleanup
        coalesce(trim(split_part(RESULT_STATUS, '^', 1)), 'NA') as RESULT_STATUS,

        -- 🧩 Convert datetime → date only
        OBSERVATION_DATE,
        -- Abnormality classification
        coalesce(
            case 
                when upper(trim(ABNORMAL_FLAGS)) in ('H', 'HIGH', 'L', 'LOW') then 'ABNORMAL'
                else 'NORMAL'
            end,
            'NA'
        ) as ABNORMALITY_STATUS
        
    from {{ ref('Observations') }}
),


--select * from cleansed_observations
deduplicated as (
    select distinct * from cleansed_observations
)


select * from deduplicated