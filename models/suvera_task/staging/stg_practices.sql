--The aim of this model is to create a replica of the raw file than can have initial data quality tests applied.
SELECT
    id,
    practice_name,
    location,
    established_date,
    pcn
FROM
    {{ ref('raw_practices') }}