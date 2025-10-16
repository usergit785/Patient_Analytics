WITH payer_base AS (
    SELECT
        PAYER_ID,
        PAYER_NAME,
        PAYER_OWNERSHIP
    FROM {{ ref('cleansed_payers') }}
),

payer_enriched AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['PAYER_ID']) }} AS payer_key,
        PAYER_ID,
        PAYER_NAME,
        PAYER_OWNERSHIP,
        CASE
            WHEN LOWER(PAYER_NAME) LIKE '%medicare%' THEN 'Medicare'
            WHEN LOWER(PAYER_NAME) LIKE '%medicaid%' THEN 'Medicaid'
            WHEN LOWER(PAYER_OWNERSHIP) = 'government' THEN 'Government'
            ELSE 'Private'
        END AS payer_type,
        CURRENT_TIMESTAMP AS dw_created_at,
        CURRENT_TIMESTAMP AS dw_updated_at
    FROM payer_base
)

SELECT * FROM payer_enriched