SELECT
    activity_id,
    --Where patient_id is null, the patient_id is set to join to an unknown patient record
    COALESCE(patient_id, -9999) AS patient_id,
    activity_type,
    activity_date as activity_timestamp,
    duration_minutes
FROM 
    {{ ref('stg_activities') }}