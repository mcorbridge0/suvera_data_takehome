--This code creates a table of activity rows with potential data quality issues.
--This can be used to identify rules that can be applied to the data, or for fixing upstream issues.
WITH activity_errors AS(
    SELECT
        act.*,
        --Checks whether patient_id is null.
        CASE WHEN pat.patient_id IS NULL THEN 1 ELSE 0 END AS patient_id_error,
        --Checks whether activity_type is null.
        CASE WHEN act.activity_type IS NULL THEN 1 ELSE 0 END AS activity_type_error,
        --Checks whether activity_timestamp is null, if activity_timestamp is in the future, if it was before the start of the company, or if it was before the patient was registered.
        CASE WHEN
            act.activity_timestamp IS NULL OR
            act.activity_timestamp > CAST(CURRENT_TIMESTAMP AS TIMESTAMP) OR
            CAST(act.activity_timestamp AS DATE) < '2019-01-01' OR
            CAST(act.activity_timestamp AS DATE) < pat.registration_date THEN 1
            ELSE 0 END AS activity_timestamp_error,
        --Checks if the duration is null, less than 0 or a day or longer.
        CASE WHEN 
            act.duration_minutes IS NULL OR
            act.duration_minutes < 0 OR
            act.duration_minutes >= 1440 THEN 1
            ELSE 0 END AS duration_minutes_error
    FROM
        {{ ref('fct_activities') }} AS act
    LEFT JOIN
        {{ ref('dim_patient') }} AS pat
        ON act.patient_id = act.patient_id
)

SELECT  
    *
FROM
    activity_errors
WHERE
    patient_id_error + activity_type_error + activity_timestamp_error + duration_minutes_error > 0