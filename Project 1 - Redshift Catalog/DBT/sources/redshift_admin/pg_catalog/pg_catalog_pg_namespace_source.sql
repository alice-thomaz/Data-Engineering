{{
  config(
    materialized = 'table',
    dist = 'pn_oid',
    sort = 'pn_nspname'
    )
}}

WITH source AS(  

    SELECT 
      "oid"::INT                  AS pn_oid, 
      nspname::VARCHAR(255)       AS pn_nspname
    FROM {{ source('pg_catalog_sc', 'pg_namespace') }}
    {% if target.name == 'dev' %}
    LIMIT 1
    {% endif %}

)

SELECT 
  pn_oid,
  pn_nspname
FROM source