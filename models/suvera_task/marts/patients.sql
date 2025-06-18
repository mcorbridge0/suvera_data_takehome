WITH agg_activities AS(
    SELECT
        patient_id,
        COUNT(DISTINCT activity_id) AS number_of_activities,
        MIN(activity_timestamp) AS first_activity_timestamp,
        MAX(activity_timestamp) AS last_activity_timestamp
    FROM
        {{ref('fct_activities') }}
    GROUP BY ALL
),

patient_conditions AS(
    SELECT
        pat.patient_id,
        MAX(CASE WHEN condition = 'frailty' THEN 1 ELSE 0 END) AS has_frailty,
        MAX(CASE WHEN condition = 'hypertension' THEN 1 ELSE 0 END) AS has_hypertension,
        MAX(CASE WHEN condition = 'asthma' THEN 1 ELSE 0 END) AS has_asthma,
        MAX(CASE WHEN condition = 'CKD' THEN 1 ELSE 0 END) AS has_ckd
    FROM
        {{ ref('dim_patient') }} AS pat,
    UNNEST(JSON_EXTRACT(conditions_list, '$')::VARCHAR[]) AS UNNESTED(condition)
    GROUP BY ALL
)

SELECT
    pat.patient_id,
    pat.practice_id,
    COALESCE(pra.practice_name, 'Unknown') AS practice_name,
    COALESCE(pra.pcn_id, -999) AS pcn_id,
    COALESCE(pcn.pcn_name, 'Unknown') as pcn_name,
    pat.age,
    CASE
        WHEN TRY_CAST(pat.age AS INT) <0 THEN NULL
        WHEN TRY_CAST(age AS INT) <=18 THEN '0 - 18'
        WHEN TRY_CAST(pat.age AS INT) <= 35 THEN '19 - 35'
        WHEN TRY_CAST(pat.age AS INT) <= 50 THEN '36 - 50'
        WHEN TRY_CAST(pat.age AS INT) <= 115 THEN '51+'
        END AS age_group,
    pat.gender,
    pat.registration_date,
    pat.conditions_list,
    COALESCE(pco.has_frailty, 0) AS has_frailty,
    COALESCE(pco.has_hypertension, 0) AS has_hypertension,
    COALESCE(pco.has_asthma, 0) AS has_asthma,
    COALESCE(pco.has_ckd, 0) AS has_ckd,
    pat.email,
    pat.phone,
    aga.number_of_activities,
    aga.first_activity_timestamp,
    aga.last_activity_timestamp
FROM
    {{ ref('dim_patient') }} AS pat
LEFT JOIN
    {{ ref('dim_practice') }} AS pra
    ON pat.practice_id = pra.practice_id
LEFT JOIN
    {{ ref('dim_pcn') }} AS pcn
    ON pra.pcn_id = pcn.pcn_id
LEFT JOIN
    agg_activities AS aga
    ON pat.patient_id = aga.patient_id
LEFT JOIN
    patient_conditions AS pco
    ON pat.patient_id = pco.patient_id