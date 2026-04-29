{{ config(
    materialized='incremental',
    schema='smei',
    alias='db_deal_rights',
    unique_key='db_id',
    incremental_strategy='merge'
) }}

SELECT
    -- ✅ no multiplication, no overflow
    db_id,

    -- ✅ required column in table
    db_id AS id,

    deal_id,
    artist_project_id,
    artist_project_title,

    master,
    master_percent,

    publishing,
    publishing_percent,

    video,
    matching,
    rofo,
    exclusions_rights,

    db_status,

    CASE 
        WHEN db_status = 'ACTIVE' THEN 1
        ELSE 0
    END AS active,

    updatedat,
    updatedby

FROM {{ ref('int_db_deal_rights') }}