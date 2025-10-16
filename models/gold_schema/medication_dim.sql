with cte as (
SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['MEDICATION_CODE']) }} AS medication_key,
    MEDICATION_CODE,
    MEDICATION_DESCRIPTION,
    CURRENT_TIMESTAMP AS dw_created_at
FROM {{ ref('cleansed_medications') }}
WHERE MEDICATION_CODE IS NOT NULL)

select * from cte