{{ config(
    materialized='view',
    schema='smei'
) }}

WITH deal_union AS (

    -- 🔹 Deal Detail
    SELECT 
        DDId AS deal_id,
        DealNo
    FROM TYTexported.dbo.t_dealdetail

    UNION ALL

    -- 🔹 Deal Amendment
    SELECT 
        DDAId AS deal_id,
        DealNo
    FROM TYTexported.dbo.t_dealdetailamendment
),

artist AS (

    SELECT
        DAId AS artist_project_id,
        ArtistName AS artist_project_title,
        Territory AS territory_id,
        DealNo
    FROM TYTexported.dbo.t_dealartist
),

master AS (

    SELECT
        DealNo,
        PartyName,
        IsSaved
    FROM TYTexported.dbo.t_dealmaster
)

SELECT

    -- ✅ CLEAN NUMERIC ID
    ROW_NUMBER() OVER (
        ORDER BY du.DealNo, a.artist_project_id
    ) AS db_id,

    -- ✅ REAL DEAL NAME
    ISNULL(m.PartyName, CONCAT('DEAL_', du.DealNo)) AS db_name,

    du.deal_id,

    a.artist_project_id,
    a.artist_project_title,
    a.territory_id,

    -- ✅ STATUS
    CASE 
        WHEN m.IsSaved = 1 THEN 'ACTIVE'
        ELSE 'INACTIVE'
    END AS db_status,

    GETDATE() AS updatedat,
    SYSTEM_USER AS updatedby

FROM deal_union du

LEFT JOIN artist a
    ON du.DealNo = a.DealNo

LEFT JOIN master m
    ON du.DealNo = m.DealNo