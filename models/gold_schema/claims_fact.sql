WITH claims_trans AS (
    SELECT
        ct.CLAIMID,
        ct.CHARGEID,
        ct.PATIENTID,
        ct.TYPE,
        ct.AMOUNT,
        ct.METHOD,
        ct.FROMDATE,
        ct.TODATE,
        ct.PLACEOFSERVICE,
        ct.PROCEDURECODE,
        ct.DIAGNOSISREF1,
        ct.UNITS,
        ct.DEPARTMENTID,
        ct.NOTES,
        ct.UNITAMOUNT,
        ct.TRANSFERTYPE,
        ct.PAYMENTS,
        ct.TRANSFERS,
        ct.OUTSTANDING,
        ct.APPOINTMENTID,
        ct.PATIENTINSURANCEID,
        ct.FEESCHEDULEID,
        ct.PROVIDERID,
        ct.SUPERVISINGPROVIDERID
    FROM {{ ref('cleaned_claims_transactions') }} ct
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['CLAIMID', 'CHARGEID']) }} AS claim_transaction_key,
    
    -- Foreign Keys
    p.patient_key,
    prov.provider_key,
    d_from.date_key AS from_date_key,
    d_to.date_key AS to_date_key,
    
    -- Degenerate Dimensions
    ct.CLAIMID AS claim_id,
    ct.CHARGEID AS charge_id,
    ct.PATIENTID AS patient_id,
    ct.TYPE AS transaction_type,
    ct.METHOD AS payment_method,
    ct.PLACEOFSERVICE AS place_of_service,
    ct.PROCEDURECODE AS procedure_code,
    ct.DIAGNOSISREF1 AS diagnosis_reference,
    ct.DEPARTMENTID AS department_id,
    ct.TRANSFERTYPE AS transfer_type,
    
    -- Measures
    ct.AMOUNT,
    ct.UNITS,
    ct.UNITAMOUNT AS unit_amount,
    ct.PAYMENTS,
    ct.TRANSFERS,
    ct.OUTSTANDING,
    (ct.AMOUNT - ct.PAYMENTS - ct.TRANSFERS) AS net_outstanding,
    
    -- Date Fields
    ct.FROMDATE AS from_date,
    ct.TODATE AS to_date,
    
    -- Audit
    CURRENT_TIMESTAMP AS dw_created_at
    
FROM claims_trans ct
LEFT JOIN {{ ref('patient_dim') }} p ON ct.PATIENTID = p.PATIENT_ID AND p.IS_CURRENT = TRUE
LEFT JOIN {{ ref('provider_dim') }} prov ON ct.PROVIDERID = prov.PROVIDER_ID
LEFT JOIN {{ ref('date_dim') }} d_from ON DATE(ct.FROMDATE) = d_from.date_value
LEFT JOIN {{ ref('date_dim') }} d_to ON DATE(ct.TODATE) = d_to.date_value

