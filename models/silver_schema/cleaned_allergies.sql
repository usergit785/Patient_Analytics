select
       distinct
     
        PATIENT,        
        COALESCE(ENCOUNTER,'NA') as encounter,
        COALESCE(cast(CODE as varchar(20)),'unknown') as code,
        COALESCE(DESCRIPTION,'unknown') as DESCRIPTION,        
        COALESCE(
            CASE WHEN POSITION('^' IN category) > 0 THEN SPLIT_PART(category, '^', 2)
        ELSE category END, 'unknown') AS category,       
        COALESCE(allergen,'unknown') as allergen,      
        COALESCE(SPLIT_PART(severity, '^', 2),'unknown') AS severity,
     
        COALESCE(REACTION_CODE,'unknown') as REACTION_CODE
      
    from {{ ref('allergies') }}