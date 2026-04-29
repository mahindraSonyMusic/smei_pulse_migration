{{ config(
    materialized='view',
    schema='smei'
) }}

SELECT
    d.DDId AS deal_id,

    a.DAId AS artist_project_id,
    a.ArtistName AS artist_project_title,

    t.id AS territory_id,

    CASE 
        WHEN m.IsSaved = 1 THEN 'ACTIVE'
        ELSE 'INACTIVE'
    END AS db_status,

    GETDATE() AS updatedat,
    SYSTEM_USER AS updatedby

FROM TYTexported.dbo.t_dealdetail d

LEFT JOIN TYTexported.dbo.t_dealartist a
    ON d.DealNo = a.DealNo

LEFT JOIN TYTexported.dbo.t_dealmaster m
    ON d.DealNo = m.DealNo

LEFT JOIN smei.met_lookup t
    ON a.Territory = t.[values]
   AND t.type = 'met_territory'