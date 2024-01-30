{{
  config(
    materialized = 'table',
    dist = 'tsrc_table_name',
    sort = 'tsrc_schema_name',
    pre_hook = "{{ governance_update_catalog('admin.tb_svv_redshift_columns', 'admin.update_tb_svv_redshift_columns') }}"
    )
}}

--Some functions are not supported as Redshift tables, so the procedure truncates the target table in the admin schema
--and then executes a loop, as recommended by AWS, to perform the insert into the target with system data.

WITH source AS(  

    SELECT 
      "database_name"         AS tsrc_database_name,
      schema_name             AS tsrc_schema_name,
      table_name              AS tsrc_table_name,
      column_name             AS tsrc_column_name,
      ordinal_position        AS tsrc_ordinal_position,
      data_type               AS tsrc_data_type,
      is_nullable             AS tsrc_is_nullable,
      "encoding"              AS tsrc_encoding,
      distkey                 AS tsrc_distkey,
      sortkey                 AS tsrc_sortkey,
      remarks                 AS tsrc_remarks
    FROM {{ source('admin_sc', 'tb_svv_redshift_columns') }}
    {% if target.name == 'dev' %}
    LIMIT 1
    {% endif %}

) 

SELECT 
  tsrc_database_name,
  tsrc_schema_name,
  tsrc_table_name,
  tsrc_column_name,
  tsrc_ordinal_position,
  tsrc_data_type,
  tsrc_is_nullable,
  tsrc_encoding,
  tsrc_distkey,
  tsrc_sortkey,
  tsrc_remarks
FROM source