{{ config(
    materialized='incremental',
    unique_key='db_id',
    incremental_strategy='merge',
    schema='smei'
) }}

WITH src AS (

    SELECT
        -- ✅ PURE INTEGER KEY
        (deal_id * 100000) + ISNULL(artist_project_id, 0) AS db_id,

        deal_id,
        artist_project_id,
        artist_project_title,
        territory_id,
        db_status,
        updatedat,
        updatedby

    FROM {{ ref('int_db_deal_territories') }}

)

SELECT * FROM src

{% if is_incremental() %}

WHERE db_id NOT IN (
    SELECT db_id FROM {{ this }}
)

{% endif %}