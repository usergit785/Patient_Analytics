    select distinct
    *
    from {{ ref('imaging_studies') }}