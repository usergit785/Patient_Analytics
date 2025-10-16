with cte as (
SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['PROCEDURE_CODE']) }} AS procedure_key,
    PROCEDURE_CODE,
    PROCEDURE_DESCRIPTION,
    REASON_CODE,
    REASON_DESCRIPTION,
    CURRENT_TIMESTAMP AS dw_created_at
FROM {{ ref('cleansed_procedures') }}
WHERE PROCEDURE_CODE IS NOT NULL)
select * from cte