{{
  config(
    materialized = 'table',
    dist = 'tpt_tablename',
    sort = 'tpt_schemaname',
    pre_hook = "{{ governance_update_catalog('admin.tb_pg_tables', 'admin.update_tb_pg_tables') }}"
    )
}}

--Some functions are not supported as Redshift tables, so the procedure truncates the target table in the admin schema
--and then executes a loop, as recommended by AWS, to perform the insert into the target with system data.

WITH source AS(  

    SELECT 
      schemaname          AS tpt_schemaname,
      tablename           AS tpt_tablename,
      tableowner          AS tpt_tableowner
    FROM {{ source('admin_sc', 'tb_pg_tables') }}
    {% if target.name == 'dev' %}
    LIMIT 1
    {% endif %}

)

SELECT 
  tpt_schemaname,
  tpt_tablename,
  tpt_tableowner
FROM source