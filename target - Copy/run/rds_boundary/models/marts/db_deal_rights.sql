
      -- back compat for old kwarg name
  
  
  
        
            
	    
	    
            
        
    

    

    merge into "pulse"."smei"."db_deal_rights" as DBT_INTERNAL_DEST
        using "pulse"."smei"."db_deal_rights__dbt_tmp" as DBT_INTERNAL_SOURCE
        on ((DBT_INTERNAL_SOURCE.db_id = DBT_INTERNAL_DEST.db_id))

    
    when matched then update set
        "db_id" = DBT_INTERNAL_SOURCE."db_id","id" = DBT_INTERNAL_SOURCE."id","deal_id" = DBT_INTERNAL_SOURCE."deal_id","artist_project_id" = DBT_INTERNAL_SOURCE."artist_project_id","artist_project_title" = DBT_INTERNAL_SOURCE."artist_project_title","master" = DBT_INTERNAL_SOURCE."master","master_percent" = DBT_INTERNAL_SOURCE."master_percent","publishing" = DBT_INTERNAL_SOURCE."publishing","publishing_percent" = DBT_INTERNAL_SOURCE."publishing_percent","video" = DBT_INTERNAL_SOURCE."video","matching" = DBT_INTERNAL_SOURCE."matching","rofo" = DBT_INTERNAL_SOURCE."rofo","exclusions_rights" = DBT_INTERNAL_SOURCE."exclusions_rights","db_status" = DBT_INTERNAL_SOURCE."db_status","updatedby" = DBT_INTERNAL_SOURCE."updatedby","updatedat" = DBT_INTERNAL_SOURCE."updatedat","active" = DBT_INTERNAL_SOURCE."active"
    

    when not matched then insert
        ("db_id", "id", "deal_id", "artist_project_id", "artist_project_title", "master", "master_percent", "publishing", "publishing_percent", "video", "matching", "rofo", "exclusions_rights", "db_status", "updatedby", "updatedat", "active")
    values
        ("db_id", "id", "deal_id", "artist_project_id", "artist_project_title", "master", "master_percent", "publishing", "publishing_percent", "video", "matching", "rofo", "exclusions_rights", "db_status", "updatedby", "updatedat", "active")

;

  