{{
  config(
    materialized = 'table',
    dist = 'tsrt_table_name',
    sort = 'tsrt_schema_name',
    )
}}

WITH svv_redshift_tables AS (       --Collects data from the svv_redshift_tables system table.

  SELECT
    tsrt_database_name,
    tsrt_schema_name,
    tsrt_table_name,
    tsrt_table_type,
    tsrt_remarks,
    CONCAT(CONCAT(tsrt_schema_name, '.'), tsrt_table_name) AS dc_schema_table
  FROM {{ ref('admin_tb_svv_redshift_tables_source') }}
  WHERE tsrt_database_name = 'your-database'

), svv_table_info AS (       --CCollects data from the svv_table_info system table.

  SELECT
    sti_schema,
    sti_table,
    sti_diststyle,
    sti_sortkey1,
    sti_unsorted,
    sti_tbl_rows,
    sti_size
  FROM {{ ref('pg_catalog_svv_table_info_source') }}
  WHERE sti_database = 'your-database'

), union_pg AS (        --Combines data from the pg_tables and pg_views system tables.

  SELECT
    tpv_schemaname AS dc_schemaname,
    tpv_viewname   AS dc_tablename,
    tpv_viewowner  AS dc_table_owner
  FROM {{ ref('admin_tb_pg_views_source') }}
  UNION
  SELECT
    tpt_schemaname AS dc_schemaname,
    tpt_tablename  AS dc_tablename,
    tpt_tableowner AS dc_table_owner
  FROM {{ ref('admin_tb_pg_tables_source') }}

), svv_redshift_columns AS (          --Collects data from the svv_redshift_columns system table.

  SELECT
    tsrc_schema_name,
    tsrc_table_name,
    tsrc_column_name,
    tsrc_ordinal_position                                      AS tsrc_column_ordinal_position,
    tsrc_data_type                                             AS tsrc_column_data_type,
    CASE WHEN tsrc_is_nullable = 'NO' THEN 'NO' ELSE 'YES' END AS dc_column_is_nullable,
    tsrc_encoding                                              AS tsrc_column_encoding,
    CASE WHEN tsrc_distkey = 0 THEN 'NO' ELSE 'YES' END        AS dc_column_distkey,
    CASE WHEN tsrc_sortkey = 0 THEN 'NO' ELSE 'YES' END        AS dc_column_sortkey,
    tsrc_remarks                                               AS tsrc_column_description
  FROM {{ ref('admin_tb_svv_redshift_columns_source') }}
  WHERE tsrc_database_name = 'your-database'

), schemas AS (          --Collects data from the pg_namespace system table.

  SELECT
    pn_oid,
    pn_nspname
  FROM {{ ref('pg_catalog_pg_namespace_source') }}

), class_info AS (          --Collects data from the pg_class_info system table.

  SELECT
    pn_nspname,
    pci_relname,
    pci_relcreationtime
  FROM {{ ref('pg_catalog_pg_class_info_source') }}
  INNER JOIN schemas
    ON pci_relnamespace = pn_oid

), datashare_base AS ( --Brings information from the datashare table that will be used as a base for some transformations.

  SELECT
    sdo_share_type,
    sdo_share_name,
    sdo_object_type,
    sdo_object_name,
    SPLIT_PART(sdo_object_name, '.', 1) AS dc_object_name_schema
  FROM {{ ref('pg_catalog_svv_datashare_objects_source') }}

), final_catalog AS (     --Final assembly of the catalog table combining Redshift data.

  SELECT
    tsrt_database_name,
    tsrt_schema_name,
    tsrt_table_name,
    tsrt_remarks        AS tsrt_table_description,
    tsrt_table_type,
    sti_diststyle       AS sti_table_diststyle,
    sti_sortkey1        AS sti_table_sortkey,
    sti_unsorted        AS sti_table_unsorted,
    sti_tbl_rows        AS sti_table_qnt_rows,
    sti_size            AS sti_table_size,
    pci_relcreationtime AS pci_table_creation_time,
    dc_table_owner,
    tsrc_column_name,
    tsrc_column_description,
    tsrc_column_ordinal_position,
    tsrc_column_data_type,
    dc_column_is_nullable,
    tsrc_column_encoding,
    dc_column_distkey,
    dc_column_sortkey,
    sdo_share_type,
    sdo_share_name,
    sdo_object_type,
    CURRENT_DATE        AS dc_manifest_last_update
  FROM svv_redshift_tables
  LEFT JOIN svv_table_info
    ON tsrt_schema_name = sti_schema
    AND tsrt_table_name = sti_table
  LEFT JOIN union_pg
    ON tsrt_schema_name = dc_schemaname
    AND tsrt_table_name = dc_tablename
  LEFT JOIN svv_redshift_columns
    ON tsrt_schema_name = tsrc_schema_name
    AND tsrt_table_name = tsrc_table_name
  LEFT JOIN class_info
    ON tsrt_schema_name = pn_nspname
    AND tsrt_table_name = pci_relname
  LEFT JOIN datashare_base
    ON dc_schema_table = sdo_object_name

)

SELECT * FROM final_catalog