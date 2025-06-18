--This code deduplicates the patients with the same patient_ids.
--Duplicated patient IDs are a major risk as activities could be associated with the wrong patient.
--Priority should be given to fixing this duplication upstream or having the logic used here verified.

--Deduplication is done based on the number of errors in the record, so the cleanest record gets used.
--This could also be done by taking the most recent registration date, but the newest record often looks incorrect in the data.
WITH patient_row_n AS(
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY practice_id_error + age_error + gender_error + registration_date_error, registration_date desc) AS dedupe_order,
        CASE WHEN COUNT(1) OVER (PARTITION BY patient_id) > 1 THEN 1 ELSE 0 END as duplication_flag
    FROM 
        {{ ref('stg_patient_errors') }}
    --Removes completely null rows
    WHERE COALESCE(patient_id, practice_id, age, gender, registration_date, conditions_list, email, phone) IS NOT NULL
)

SELECT
    patient_id,
    --Sets null practice_ids to the id of the unknown practice entry.
    --It also sets practice_id to -999 when it is invalid which will point to a new dummy record.
    CASE WHEN practice_id = '"invalid"' THEN 999
        ELSE COALESCE(practice_id, 999) END AS practice_id,
    --Converts age to an integer and nulls any ages of an invalid type.
    TRY_CAST(age AS INT) AS age,
    gender,
    registration_date,
    conditions_list,
    email,
    phone,
    duplication_flag
FROM 
    patient_row_n
WHERE dedupe_order = 1


UNION

--Creates an unknown patient record to match to activities with a null patient_id
SELECT
    -9999,
    999,
    null,
    null,
    '1900-01-01',
    null,
    null,
    null,
    null
