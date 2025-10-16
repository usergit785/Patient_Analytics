WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2000-01-01' as date)",
        end_date="cast('2030-12-31' as date)"
    ) }}
),

date_enriched AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['date_day']) }} AS date_key,
        date_day AS date_value,
        YEAR(date_day) AS year,
        QUARTER(date_day) AS quarter,
        MONTH(date_day) AS month,
        MONTHNAME(date_day) AS month_name,
        WEEK(date_day) AS week_of_year,
        DAY(date_day) AS day_of_month,
        DAYOFWEEK(date_day) AS day_of_week,
        DAYNAME(date_day) AS day_name,
        DAYOFYEAR(date_day) AS day_of_year,
        CASE
            WHEN DAYOFWEEK(date_day) IN (1, 7) THEN TRUE
            ELSE FALSE
        END AS is_weekend,
        CASE
            WHEN DAYOFWEEK(date_day) NOT IN (1, 7) THEN TRUE
            ELSE FALSE
        END AS is_weekday,
        CONCAT(YEAR(date_day), '-Q', QUARTER(date_day)) AS year_quarter,
        TO_CHAR(date_day, 'YYYY-MM') AS year_month,
        LAST_DAY(date_day) AS last_day_of_month,
        CASE
            WHEN date_day = LAST_DAY(date_day) THEN TRUE
            ELSE FALSE
        END AS is_month_end,
        CURRENT_TIMESTAMP AS dw_created_at
    FROM date_spine
)

SELECT * FROM date_enriched