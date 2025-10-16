WITH provider_base AS (
    SELECT
        PROVIDER_ID,
        ORGANIZATION_ID,
        PROVIDER_NAME,
        GENDER,
        SPECIALTY,
        ADDRESS,
        CITY,
        STATE,
        ZIP,
        LATITUDE,
        LONGITUDE,
        ENCOUNTER_COUNT,
        PROCEDURE_COUNT
    FROM {{ ref('cleansed_providers') }}
),

provider_enriched AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['PROVIDER_ID']) }} AS provider_key,
        PROVIDER_ID,
        ORGANIZATION_ID,
        PROVIDER_NAME,
        GENDER,
        SPECIALTY,
        COALESCE(SPECIALTY, 'General Practice') AS specialty_normalized,
        ADDRESS,
        CITY,
        STATE,
        ZIP,
        LATITUDE,
        LONGITUDE,
        ENCOUNTER_COUNT,
        PROCEDURE_COUNT,
        CASE
            WHEN ENCOUNTER_COUNT >= 1000 THEN 'High Volume'
            WHEN ENCOUNTER_COUNT BETWEEN 500 AND 999 THEN 'Medium Volume'
            WHEN ENCOUNTER_COUNT < 500 THEN 'Low Volume'
            ELSE 'Unknown'
        END AS provider_volume_category,
        CASE 
            WHEN ENCOUNTER_COUNT > 0 THEN ROUND(PROCEDURE_COUNT::FLOAT / ENCOUNTER_COUNT, 2)
            ELSE 0
        END AS avg_procedures_per_encounter,
        CURRENT_TIMESTAMP AS dw_created_at,
        CURRENT_TIMESTAMP AS dw_updated_at
    FROM provider_base
)

SELECT * FROM provider_enriched