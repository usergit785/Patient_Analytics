-- models/gold/dimensions/dim_patient.sql
-- Dimension: Patient demographics with SCD Type 2 for tracking changes
WITH patient_base AS (
    SELECT
        PATIENT_ID,
        FIRST_NAME,
        LAST_NAME,
        BIRTHDATE,
        DEATHDATE,
        ACCOUNT_NUMBER,
        GENDER,
        RACE,
        LANGUAGE,
        MARITAL_STATUS,
        ETHNICITY,
        BIRTHPLACE,
        ADDRESS,
        CITY,
        STATE,
        COUNTY,
        FIPS,
        LATITUDE,
        LONGITUDE,
        HEALTHCARE_EXPENSES,
        HEALTHCARE_COVERAGE,
        INCOME,
        CURRENT_TIMESTAMP AS EFFECTIVE_START_DATE,
        NULL AS EFFECTIVE_END_DATE,
        TRUE AS IS_CURRENT
    FROM {{ ref('cleaned_patients') }}
),

patient_enriched AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['PATIENT_ID', 'EFFECTIVE_START_DATE']) }} AS patient_key,
        PATIENT_ID,
        FIRST_NAME,
        LAST_NAME,
        CONCAT(FIRST_NAME, ' ', LAST_NAME) AS full_name,
        BIRTHDATE,
        DEATHDATE,
        CASE 
            WHEN DEATHDATE IS NOT NULL THEN TRUE 
            ELSE FALSE 
        END AS is_deceased,
        DATEDIFF(YEAR, BIRTHDATE, COALESCE(DEATHDATE, CURRENT_DATE())) AS age,
        CASE
            WHEN DATEDIFF(YEAR, BIRTHDATE, COALESCE(DEATHDATE, CURRENT_DATE())) < 18 THEN 'Pediatric'
            WHEN DATEDIFF(YEAR, BIRTHDATE, COALESCE(DEATHDATE, CURRENT_DATE())) BETWEEN 18 AND 64 THEN 'Adult'
            ELSE 'Senior'
        END AS age_group,
        ACCOUNT_NUMBER,
        GENDER,
        RACE,
        LANGUAGE,
        MARITAL_STATUS,
        ETHNICITY,
        BIRTHPLACE,
        ADDRESS,
        CITY,
        STATE,
        COUNTY,
        FIPS,
        LATITUDE,
        LONGITUDE,
        HEALTHCARE_EXPENSES,
        HEALTHCARE_COVERAGE,
        INCOME,
        CASE
            WHEN INCOME < 30000 THEN 'Low Income'
            WHEN INCOME BETWEEN 30000 AND 75000 THEN 'Middle Income'
            WHEN INCOME > 75000 THEN 'High Income'
            ELSE 'Unknown'
        END AS income_bracket,
        EFFECTIVE_START_DATE,
        EFFECTIVE_END_DATE,
        IS_CURRENT,
        CURRENT_TIMESTAMP AS dw_created_at,
        CURRENT_TIMESTAMP AS dw_updated_at
    FROM patient_base
)

SELECT * FROM patient_enriched
