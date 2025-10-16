WITH observations AS (
    SELECT
        PATIENT_ID,
        VALUE_TYPE,
        OBSERVATION_CODE,
        OBSERVATION_VALUE,
        UNITS,
        REF_RANGE_LOW,
        REF_RANGE_HIGH,
        ABNORMAL_FLAG,
        RESULT_STATUS,
        OBSERVATION_DATE,
        ABNORMALITY_STATUS
    FROM {{ ref('cleansed_observations') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['o.PATIENT_ID', 'o.OBSERVATION_CODE', 'o.OBSERVATION_DATE']) }} AS observation_key,
    
    -- Foreign Keys
    p.patient_key,
    d.date_key AS observation_date_key,
    
    -- Degenerate Dimensions
    o.PATIENT_ID,
    o.OBSERVATION_CODE,
    o.VALUE_TYPE,
    o.UNITS,
    o.RESULT_STATUS,
    o.ABNORMAL_FLAG,
    o.ABNORMALITY_STATUS,
    
    -- Measures
    o.OBSERVATION_VALUE AS observation_value_numeric,
    o.OBSERVATION_VALUE AS observation_value_text,
    o.REF_RANGE_LOW,
    o.REF_RANGE_HIGH,
    CASE
        WHEN o.ABNORMAL_FLAG = 'Y' OR o.ABNORMALITY_STATUS IS NOT NULL THEN 1
        ELSE 0
    END AS is_abnormal,
    
    -- Date Fields
    o.OBSERVATION_DATE,
    
    -- Audit
    CURRENT_TIMESTAMP AS dw_created_at
    
FROM observations o
LEFT JOIN {{ ref('patient_dim') }} p ON o.PATIENT_ID = p.PATIENT_ID AND p.IS_CURRENT = TRUE
LEFT JOIN {{ ref('date_dim') }} d ON DATE(o.OBSERVATION_DATE) = d.date_value

