WITH immunizations AS (
    SELECT
        ADMINISTRATION_DATE,
        PATIENT_ID,
        ENCOUNTER,
        CODE,
        DESCRIPTION,
        VACCINE_DISPLAY,
        BASE_COST
    FROM {{ ref('cleaned_immunizations') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['i.PATIENT_ID', 'i.CODE', 'i.ADMINISTRATION_DATE']) }} AS immunization_key,
    
    -- Foreign Keys
    p.patient_key,
    d.date_key AS administration_date_key,
    
    -- Degenerate Dimensions
    i.PATIENT_ID,
    i.ENCOUNTER AS encounter_id,
    i.CODE AS vaccine_code,
    i.DESCRIPTION AS vaccine_description,
    i.VACCINE_DISPLAY,
    
    -- Measures
    i.BASE_COST AS immunization_cost,
    
    -- Date Fields
    i.ADMINISTRATION_DATE,
    
    -- Derived Fields
    CASE
        WHEN LOWER(i.DESCRIPTION) LIKE '%covid%' THEN 'COVID-19'
        WHEN LOWER(i.DESCRIPTION) LIKE '%influenza%' OR LOWER(i.DESCRIPTION) LIKE '%flu%' THEN 'Influenza'
        WHEN LOWER(i.DESCRIPTION) LIKE '%hepatitis%' THEN 'Hepatitis'
        WHEN LOWER(i.DESCRIPTION) LIKE '%hpv%' THEN 'HPV'
        WHEN LOWER(i.DESCRIPTION) LIKE '%measles%' OR LOWER(i.DESCRIPTION) LIKE '%mmr%' THEN 'MMR'
        WHEN LOWER(i.DESCRIPTION) LIKE '%pneumo%' THEN 'Pneumococcal'
        WHEN LOWER(i.DESCRIPTION) LIKE '%tdap%' OR LOWER(i.DESCRIPTION) LIKE '%tetanus%' THEN 'Tetanus/DTaP'
        ELSE 'Other'
    END AS vaccine_category,
    
    -- Audit
    CURRENT_TIMESTAMP AS dw_created_at
    
FROM immunizations i
LEFT JOIN {{ ref('patient_dim') }} p ON i.PATIENT_ID = p.PATIENT_ID AND p.IS_CURRENT = TRUE
LEFT JOIN {{ ref('date_dim') }} d ON DATE(i.ADMINISTRATION_DATE) = d.date_value
