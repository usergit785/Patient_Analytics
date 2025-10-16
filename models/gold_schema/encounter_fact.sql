WITH encounters AS (
    SELECT
        e.PATIENT_ID,
        e.ORGANIZATION,
        e.PROVIDER,
        e.PAYER,
        e.ENCOUNTERCLASS,
        e.START_DATE,
        e.END_DATE,
        e.ENCOUNTER_CODE,
        e.DESCRIPTION,
        e.BASE_ENCOUNTER_COST,
        e.TOTAL_CLAIM_COST,
        e.PAYER_COVERAGE,
        e.REASONCODE,
        e.REASONDESCRIPTION
    FROM {{ ref('cleaned_encounters') }} e
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['e.PATIENT_ID', 'e.START_DATE', 'e.PROVIDER']) }} AS encounter_key,
    
    -- Foreign Keys
    p.patient_key,
    prov.provider_key,
    org.organization_key,
    pay.payer_key,
    d_start.date_key AS start_date_key,
    d_end.date_key AS end_date_key,
    
    -- Degenerate Dimensions
    e.PATIENT_ID,
    e.ENCOUNTER_CODE,
    e.ENCOUNTERCLASS AS encounter_class,
    e.DESCRIPTION AS encounter_description,
    e.REASONCODE AS reason_code,
    e.REASONDESCRIPTION AS reason_description,
    
    -- Measures
    e.BASE_ENCOUNTER_COST,
    e.TOTAL_CLAIM_COST,
    e.PAYER_COVERAGE,
    (e.TOTAL_CLAIM_COST - e.PAYER_COVERAGE) AS patient_responsibility,
    
    -- Date Fields
    e.START_DATE,
    e.END_DATE,
    DATEDIFF(DAY, e.START_DATE, e.END_DATE) AS length_of_stay_days,
    
    -- Audit
    CURRENT_TIMESTAMP AS dw_created_at
    
FROM encounters e
LEFT JOIN {{ ref('patient_dim') }} p 
    ON e.PATIENT_ID = p.PATIENT_ID AND p.IS_CURRENT = TRUE
LEFT JOIN {{ ref('provider_dim') }} prov 
    ON e.PROVIDER = prov.PROVIDER_ID
LEFT JOIN {{ ref('organization_dim') }} org 
    ON e.ORGANIZATION = org.ORGANIZATION_ID
LEFT JOIN {{ ref('payer_dim') }} pay 
    ON e.PAYER = pay.PAYER_ID
LEFT JOIN {{ ref('date_dim') }} d_start 
    ON DATE(e.START_DATE) = d_start.date_value
LEFT JOIN {{ ref('date_dim') }} d_end 
    ON DATE(e.END_DATE) = d_end.date_value
