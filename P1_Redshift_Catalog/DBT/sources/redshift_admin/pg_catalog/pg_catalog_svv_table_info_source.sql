{{
  config(
    materialized = 'table',
    dist = 'sti_table',
    sort = 'sti_schema'
    )
}}

WITH source AS(  

    SELECT 
      "database"               AS sti_database,
      "schema"                 AS sti_schema,
      table_id::INT            AS sti_table_id,
      "table"                  AS sti_table,
      encoded                  AS sti_encoded,
      diststyle                AS sti_diststyle,
      sortkey1                 AS sti_sortkey1,
      max_varchar              AS sti_max_varchar,
      sortkey1_enc             AS sti_sortkey1_enc,
      sortkey_num              AS sti_sortkey_num,
      size                     AS sti_size,
      pct_used                 AS sti_pct_used,
      unsorted                 AS sti_unsorted,
      stats_off                AS sti_stats_off,
      tbl_rows                 AS sti_tbl_rows,
      skew_sortkey1            AS sti_skew_sortkey1,
      skew_rows                AS sti_skew_rows,
      estimated_visible_rows   AS sti_estimated_visible_rows,
      vacuum_sort_benefit      AS sti_vacuum_sort_benefit 
    FROM {{ source('pg_catalog_sc', 'svv_table_info') }}
    {% if target.name == 'dev' %}
    LIMIT 1
    {% endif %}

)

SELECT 
  sti_database,
  sti_schema,
  sti_table_id,
  sti_table,
  sti_encoded,
  sti_diststyle,
  sti_sortkey1,
  sti_max_varchar,
  sti_sortkey1_enc,
  sti_sortkey_num,
  sti_size,
  sti_pct_used,
  sti_unsorted,
  sti_stats_off,
  sti_tbl_rows,
  sti_skew_sortkey1,
  sti_skew_rows,
  sti_estimated_visible_rows,
  sti_vacuum_sort_benefit
FROM source