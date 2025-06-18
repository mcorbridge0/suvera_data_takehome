--The raw_patients seed is in JSON format. This code transforms it into a usable format.
--The aim of this model is to create a tabular version of the raw file than can have initial data quality tests applied.
WITH extracted_json AS(
    SELECT *,
        JSON_EXTRACT(data, '$.patient_id') AS patient_id,
        JSON_EXTRACT(data, '$.practice_id') AS practice_id,
        JSON_EXTRACT(data, '$.age') AS age,
        REPLACE(JSON_EXTRACT(data, '$.gender'),'"','') AS gender,
        CAST(REPLACE(JSON_EXTRACT(data, '$.registration_date'),'"','') AS DATE) AS registration_date,
        JSON_EXTRACT(data, '$.conditions') AS conditions_list,
        JSON_EXTRACT(data, '$.contact') AS contact
    FROM {{ ref('raw_patients') }}


)

SELECT
    patient_id,
    practice_id,
    age,
    gender,
    registration_date,
    conditions_list,
    REPLACE(JSON_EXTRACT(contact, '$.email'),'"','') AS email,
    REPLACE(JSON_EXTRACT(contact, '$.phone'),'"','') AS phone
FROM extracted_json