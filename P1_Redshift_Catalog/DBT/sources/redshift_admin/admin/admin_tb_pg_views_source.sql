{{
  config(
    materialized = 'table',
    dist = 'tpv_viewname',
    sort = 'tpv_schemaname',
    pre_hook = "{{ governance_update_catalog('admin.tb_pg_views', 'admin.update_tb_pg_views') }}"
    )
}}

--Some functions are not supported as Redshift tables, so the procedure truncates the target table in the admin schema
--and then executes a loop, as recommended by AWS, to perform the insert into the target with system data.

WITH source AS(  

    SELECT 
      schemaname             AS tpv_schemaname,
      viewname               AS tpv_viewname,
      viewowner              AS tpv_viewowner
    FROM {{ source('admin_sc', 'tb_pg_views') }}
    {% if target.name == 'dev' %}
    LIMIT 1
    {% endif %}

)

SELECT 
  tpv_schemaname,
  tpv_viewname,
  tpv_viewowner
FROM source