--The aim of this model is to create a replica of the raw file than can have initial data quality tests applied.
SELECT
    id,
    pcn_name
FROM
    {{ ref('raw_pcns') }}