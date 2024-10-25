WITH raw_mobility AS (
    SELECT
        hds.staff_id,
        hsm.date_of_mobility,
        trim(regexp_replace(lower(NULLIF(hsm.previous_role, '#REF!')), '\r', '')) AS job_title,
        hsc.start_date AS onboarding_date
    FROM
        {{ source('superside', 'hr_staff_mobility') }} AS hsm
    LEFT JOIN {{ source('superside', 'db_staff') }} AS hds
        ON
            hsm._name = hds._name
    LEFT JOIN {{ source('superside', 'hr_staff_current') }} AS hsc
        ON
            hsm._name = hsc._name
    WHERE
        hsm._name IS NOT NULL AND NULLIF(hsm.previous_role, '#REF!') IS NOT NULL
),
current_roles AS (
    SELECT
        hds.staff_id,
        TODAY() AS date_of_mobility,
        trim(regexp_replace(lower(NULLIF(hsc._role, '#REF!')), '\r', '')) AS job_title,
        hsc.start_date AS onboarding_date
    FROM
        {{ source('superside', 'hr_staff_current') }} AS hsc
    LEFT JOIN {{ source('superside', 'db_staff') }} AS hds ON
        hsc._name = hds._name
),

raw_promotions AS (
    SELECT *
    FROM
        raw_mobility
    UNION
    SELECT *
    FROM
        current_roles
),

promotions_mid AS (
    SELECT
        staff_id,
        job_title,
        onboarding_date,
        MIN(date_of_mobility) AS end_date
    FROM
        raw_promotions
    GROUP BY
        1,
        2,
        3
    ORDER BY
        1,
        4 DESC
)

SELECT
    staff_id,
    job_title,
    COALESCE(LEAD(
    end_date,
        1
    ) OVER (PARTITION BY staff_id),
    onboarding_date) AS start_date,
    nullif(end_date, today()) as end_date
FROM
    promotions_mid
order by 1
