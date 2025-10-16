WITH medications AS (
    SELECT
        PATIENT_ID,
        ENCOUNTER_ID,
        MEDICATION_CODE,
        MEDICATION_DESCRIPTION,
        MEDICATION_START_DATE,
        MEDICATION_END_DATE
    FROM {{ ref('cleansed_medications') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['m.PATIENT_ID', 'm.ENCOUNTER_ID', 'm.MEDICATION_CODE', 'm.MEDICATION_START_DATE']) }} AS medication_key,
    
    -- Foreign Keys
    p.patient_key,
    med_dim.medication_key AS medication_dim_key,
    d_start.date_key AS medication_start_date_key,
    d_end.date_key AS medication_end_date_key,
    
    -- Degenerate Dimensions
    m.PATIENT_ID,
    m.ENCOUNTER_ID,
    m.MEDICATION_CODE,
    m.MEDICATION_DESCRIPTION,
    
    -- Date Fields
    m.MEDICATION_START_DATE,
    m.MEDICATION_END_DATE,
    DATEDIFF(DAY, m.MEDICATION_START_DATE, COALESCE(m.MEDICATION_END_DATE, CURRENT_DATE())) AS medication_duration_days,
    CASE
        WHEN m.MEDICATION_END_DATE IS NULL THEN 1
        ELSE 0
    END AS is_active_medication,
    
    -- Audit
    CURRENT_TIMESTAMP AS dw_created_at
    
FROM medications m
LEFT JOIN {{ ref('patient_dim') }} p ON m.PATIENT_ID = p.PATIENT_ID AND p.IS_CURRENT = TRUE
LEFT JOIN {{ ref('medication_dim') }} med_dim ON m.MEDICATION_CODE = med_dim.MEDICATION_CODE
LEFT JOIN {{ ref('date_dim') }} d_start ON DATE(m.MEDICATION_START_DATE) = d_start.date_value
LEFT JOIN {{ ref('date_dim') }} d_end ON DATE(m.MEDICATION_END_DATE) = d_end.date_value
