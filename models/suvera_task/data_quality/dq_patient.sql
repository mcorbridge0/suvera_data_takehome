--This code creates a table of patient rows with potential data quality issues.
--This can be used to identify rules that can be applied to the data, or for fixing upstream issues.
--Most errors have already been calculated in stg_patient_errors.
SELECT
    *,
    --Includes rows with duplicate patient_ids
    CASE WHEN rows_with_same_id > 1 THEN 1 ELSE 0 END AS duplication_error
FROM
    {{ ref('stg_patient_errors') }}
WHERE
    patient_id_error + practice_id_error + age_error + gender_error + registration_date_error > 1
    OR rows_with_same_id > 1
