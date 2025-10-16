   select  distinct
    ID,
	"START" as start_date,
	PATIENT,
	ENCOUNTER,
	CODE,
	DESCRIPTION,
	coalesce(REASONCODE,-1) as REASONCODE,
	coalesce(REASONDESCRIPTION,'unknown') as REASONDESCRIPTION
    from {{ ref('careplans') }}