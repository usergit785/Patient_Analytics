with cte as (
SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['CODE']) }} AS diagnosis_key,
    CODE AS diagnosis_code,
    DESCRIPTION AS diagnosis_description,
    DIAGNOSIS_CODING_METHOD AS coding_method,
    SUBSTRING(CODE, 1, 3) AS diagnosis_category,
    CURRENT_TIMESTAMP AS dw_created_at
FROM {{ ref('cleaned_diagnosis') }}
WHERE CODE IS NOT NULL)
select * from cte
