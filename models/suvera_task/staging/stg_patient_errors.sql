--This model identifies potential data quality issues with the patients data.
--This is used to deduplicate in the patients in the next step, as well as populating the dq_patient table of data quality issues.
SELECT
    patient_id,
    practice_id,
    age,
    gender,
    registration_date,
    conditions_list,
    email,
    phone,
    --Checks whether patient_id is null or unknown.
    CASE WHEN patient_id IS NULL OR TRY_CAST(patient_id AS INT) = -9999 THEN 1 ELSE 0 END AS patient_id_error,
    --Checks whether practice_id is null or unknown.
    CASE WHEN practice_id IS NULL OR TRY_CAST(practice_id AS INT) = 999 THEN 1 ELSE 0 END AS practice_id_error,
    --Checks whether the age is null, invalid type, over 115 or less than 0.
    CASE WHEN age IS NULL OR TRY_CAST(age AS INT) > 115 OR TRY_CAST(age AS INT) < 0 THEN 1 ELSE 0 END AS age_error,
    --Checks if gender is null or not in the accepted values.
    CASE WHEN gender IS NULL OR gender NOT IN ('M','F','X') THEN 1 ELSE 0 END AS gender_error,
    --Checks if the registration_date is null.
    CASE WHEN registration_date IS NULL THEN 1 ELSE 0 END AS registration_date_error,
    --Counts the number of patients with the same patient_id.
    COUNT(1) OVER (PARTITION BY patient_id) AS rows_with_same_id
FROM 
    {{ ref('stg_patients') }}