
WITH organization_base AS (
    SELECT
        ORGANIZATION_ID,
        ORGANIZATION_NAME,
        ADDRESS,
        CITY,
        ZIP,
        LATITUDE,
        LONGITUDE,
        CONTACT_NUMBER,
        UTILIZATION
    FROM {{ ref('cleansed_organizations') }}
),

organization_enriched AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['ORGANIZATION_ID']) }} AS organization_key,
        ORGANIZATION_ID,
        ORGANIZATION_NAME,
        ADDRESS,
        CITY,
        ZIP,
        LATITUDE,
        LONGITUDE,
        CONTACT_NUMBER,
        UTILIZATION,
        CASE
            WHEN UTILIZATION >= 10000 THEN 'Large Facility'
            WHEN UTILIZATION BETWEEN 5000 AND 9999 THEN 'Medium Facility'
            WHEN UTILIZATION < 5000 THEN 'Small Facility'
            ELSE 'Unknown'
        END AS facility_size,
        CURRENT_TIMESTAMP AS dw_created_at,
        CURRENT_TIMESTAMP AS dw_updated_at
    FROM organization_base
)

SELECT * FROM organization_enriched