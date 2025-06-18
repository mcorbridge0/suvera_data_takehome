SELECT
    id as practice_id,
    practice_name,
    location,
    established_date,
    --Sets null pcn_ids to -999 which matches a dummy record for unknown pcn in dim_pcn.
    COALESCE(pcn, -999) as pcn_id
FROM
    {{ ref('stg_practices') }}