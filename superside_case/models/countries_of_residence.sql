WITH residences_from_current AS (
    SELECT
        hds.staff_id,
        hsc.residence
    FROM
        {{ source('superside', 'hr_staff_current') }} AS hsc
    INNER JOIN {{ source('superside', 'db_staff') }} AS hds ON
        hsc._name = hds._name
),

residencies_from_current_parsed AS (
    SELECT
        rfc.staff_id,
        cl.iso_code AS residence
    FROM
        residences_from_current AS rfc
    LEFT JOIN {{ ref('countries_lookup') }} AS cl ON
        rfc.residence = cl.country_name
),

residences_from_staff AS (
    SELECT
        staff_id,
        NULLIF(
            residence,
            '#N/A'
        ) AS residence
    FROM
        {{ source('superside', 'db_staff') }}
),

residencies_from_staff_parsed AS (
    SELECT
        rfs.staff_id,
        cl.iso_code AS residence
    FROM
        residences_from_staff AS rfs
    LEFT JOIN {{ ref('countries_lookup') }} AS cl
        ON
            rfs.residence = cl.country_name
    WHERE
        residence IS NOT NULL
)

SELECT
    rfsp.staff_id,
    rfsp.residence AS residence_from_staff,
    rfcp.residence AS residence_from_current
FROM
    residencies_from_staff_parsed AS rfsp
LEFT JOIN residencies_from_current_parsed AS rfcp
    ON rfsp.staff_id = rfcp.staff_id
