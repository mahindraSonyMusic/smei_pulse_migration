{{ config(
    materialized='view',
    schema='smei'
) }}

WITH deal_union AS (

    SELECT 
        DDId AS deal_id,
        DealNo
    FROM TYTexported.dbo.t_dealdetail

    UNION ALL

    SELECT 
        DDAId AS deal_id,
        DealNo
    FROM TYTexported.dbo.t_dealdetailamendment
),

artist AS (

    SELECT
        DAId AS artist_project_id,
        ArtistName AS artist_project_title,

        MasterRight,
        PublishingRight,
        VideoRight,
        Matching,
        Exclusion,

        DealNo
    FROM TYTexported.dbo.t_dealartist
),

master AS (

    SELECT
        DealNo,
        IsSaved,
        CreatedDate,
        ModifiedDate,
        CreatedBy,
        ModifiedBy
    FROM TYTexported.dbo.t_dealmaster
)

SELECT

    -- ✅ FIXED (NO OVERFLOW)
    ABS(CHECKSUM(du.deal_id, a.artist_project_id)) AS db_id,

    du.deal_id,

    a.artist_project_id,
    a.artist_project_title,

    CASE 
        WHEN UPPER(LTRIM(RTRIM(a.MasterRight))) = 'Y' THEN 1
        ELSE 0
    END AS master,
    NULL AS master_percent,

    CASE 
        WHEN UPPER(LTRIM(RTRIM(a.PublishingRight))) = 'Y' THEN 1
        ELSE 0
    END AS publishing,
    NULL AS publishing_percent,

    CASE 
        WHEN UPPER(LTRIM(RTRIM(a.VideoRight))) = 'Y' THEN 1
        ELSE 0
    END AS video,

    CASE 
        WHEN UPPER(LTRIM(RTRIM(a.Matching))) = 'Y' THEN 1
        ELSE 0
    END AS matching,

    CAST(0 AS BIT) AS rofo,

    a.Exclusion AS exclusions_rights,

    CASE 
        WHEN m.IsSaved = 1 THEN 'ACTIVE'
        ELSE 'INACTIVE'
    END AS db_status,

    COALESCE(m.ModifiedDate, m.CreatedDate) AS updatedat,
    COALESCE(m.ModifiedBy, m.CreatedBy)     AS updatedby

FROM deal_union du

LEFT JOIN artist a
    ON du.DealNo = a.DealNo

LEFT JOIN master m
    ON du.DealNo = m.DealNo