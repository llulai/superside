WITH unnested_nationalities_from_current AS (
    SELECT
        hds.staff_id,
        trim(unnest(string_split(replace(hsc.nationality, '.', ','), ',')))
            AS nationality
    FROM
        {{ source('superside', 'hr_staff_current') }} AS hsc
    INNER JOIN {{ source('superside', 'db_staff') }} AS hds
        ON
            hsc._name = hds._name
),

nationalities_from_current AS (
    SELECT
        unfc.staff_id,
        cl.iso_code AS nationality
    FROM
        unnested_nationalities_from_current AS unfc
    LEFT JOIN {{ ref('countries_lookup') }} AS cl ON
        unfc.nationality = cl.country_name
),

unnested_nationalities_from_staff AS (
    SELECT
        staff_id,
        nullif(
            trim(unnest(string_split(replace(citizenship, '.', ','), ','))),
            '#N/A'
        ) AS nationality
    FROM
        {{source('superside', 'db_staff')}}
),

nationalities_from_staff AS (
    SELECT
        unfs.staff_id,
        cl.iso_code AS nationality
    FROM
        unnested_nationalities_from_staff AS unfs
    LEFT JOIN {{ ref('countries_lookup') }} AS cl
        ON
            unfs.nationality = cl.country_name
    WHERE
        unfs.nationality IS NOT NULL
),

all_nationalities AS (
    SELECT
        nfs.staff_id,
        nfs.nationality AS nationality_from_staff,
        nfc.nationality AS nationality_from_current
    FROM
        nationalities_from_staff AS nfs
    LEFT JOIN
        nationalities_from_current AS nfc
        ON nfs.staff_id = nfc.staff_id
)

SELECT
    staff_id,
    array_agg(nationality_from_staff) AS nationality_from_staff,
    array_agg(nationality_from_current) AS nationality_from_current
FROM
    all_nationalities
GROUP BY
    1
