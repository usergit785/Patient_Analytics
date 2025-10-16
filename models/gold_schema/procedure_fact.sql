WITH procedures AS (
    SELECT
        PATIENT_ID,
        ENCOUNTER_ID,
        PROCEDURE_CODE,
        PROCEDURE_DESCRIPTION,
        PROCEDURE_START_DATE,
        PROCEDURE_END_DATE,
        BASE_COST,
        REASON_CODE,
        REASON_DESCRIPTION
    FROM {{ ref('cleansed_procedures') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['pr.PATIENT_ID', 'pr.ENCOUNTER_ID', 'pr.PROCEDURE_CODE', 'pr.PROCEDURE_START_DATE']) }} AS procedure_key,
    
    -- Foreign Keys
    p.patient_key,
    proc_dim.procedure_key AS procedure_dim_key,
    d_start.date_key AS procedure_start_date_key,
    d_end.date_key AS procedure_end_date_key,
    
    -- Degenerate Dimensions
    pr.PATIENT_ID,
    pr.ENCOUNTER_ID,
    pr.PROCEDURE_CODE,
    pr.PROCEDURE_DESCRIPTION,
    pr.REASON_CODE,
    pr.REASON_DESCRIPTION,
    
    -- Measures
    pr.BASE_COST AS procedure_cost,
    
    -- Date Fields
    pr.PROCEDURE_START_DATE,
    pr.PROCEDURE_END_DATE,
    DATEDIFF(MINUTE, pr.PROCEDURE_START_DATE, pr.PROCEDURE_END_DATE) AS procedure_duration_minutes,
    DATEDIFF(HOUR, pr.PROCEDURE_START_DATE, pr.PROCEDURE_END_DATE) AS procedure_duration_hours,
    
    -- Audit
    CURRENT_TIMESTAMP AS dw_created_at
    
FROM procedures pr
LEFT JOIN {{ ref('patient_dim') }} p ON pr.PATIENT_ID = p.PATIENT_ID AND p.IS_CURRENT = TRUE
LEFT JOIN {{ ref('procedure_dim') }} proc_dim ON pr.PROCEDURE_CODE = proc_dim.PROCEDURE_CODE
LEFT JOIN {{ ref('date_dim') }} d_start ON DATE(pr.PROCEDURE_START_DATE) = d_start.date_value
LEFT JOIN {{ ref('date_dim') }} d_end ON DATE(pr.PROCEDURE_END_DATE) = d_end.date_value
