SELECT
    id as pcn_id,
    pcn_name
FROM
    {{ ref('stg_pcns') }}

--Adds a new dummy record for unknown PCN
UNION

SELECT
    -999,
    'Unknown'