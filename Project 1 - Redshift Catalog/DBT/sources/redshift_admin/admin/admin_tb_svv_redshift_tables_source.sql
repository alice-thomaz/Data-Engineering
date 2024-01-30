{{
  config(
    materialized = 'table',
    dist = 'tsrt_table_name',
    sort = 'tsrt_schema_name',
    pre_hook = "{{ governance_update_catalog('admin.tb_svv_redshift_tables', 'admin.update_tb_svv_redshift_tables') }}"
    )
}}

--Some functions are not supported as Redshift tables, so the procedure truncates the target table in the admin schema
--and then executes a loop, as recommended by AWS, to perform the insert into the target with system data.

WITH source AS(  

    SELECT 
      "database_name"    AS tsrt_database_name,
      schema_name        AS tsrt_schema_name,
      table_name         AS tsrt_table_name,
      table_type         AS tsrt_table_type,
      remarks            AS tsrt_remarks
    FROM {{ source('admin_sc', 'tb_svv_redshift_tables') }}
    {% if target.name == 'dev' %}
    LIMIT 1
    {% endif %}

)

SELECT 
  tsrt_database_name,
  tsrt_schema_name,
  tsrt_table_name,
  tsrt_table_type,
  tsrt_remarks
FROM source