--The aim of this model is to create a replica of the raw file than can have initial data quality tests applied.
SELECT 
    activity_id,
    patient_id,
    activity_type,
    activity_date,
    duration_minutes
FROM 
    {{ ref('raw_activities') }}