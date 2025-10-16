SELECT DISTINCT
    -- 🧩 Identifiers
    COALESCE(TRY_CAST(diagnosis_sequence AS INTEGER), 0) AS diagnosis_sequence,
    COALESCE(diagnosis_coding_method, 'unknown') AS diagnosis_coding_method,

    -- 📅 Dates (only date part)
     start_date,
    COALESCE(end_date,to_date('1900-01-01'))AS end_date,

    -- 🧑‍⚕️ Patient Info
    patient,
    CAST(code AS VARCHAR(50)) AS code,
    description

FROM {{ ref('diagnosis') }}