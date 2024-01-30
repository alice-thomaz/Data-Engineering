{{
  config(
    materialized = 'table',
    dist = 'sdo_object_name',
    sort = 'sdo_share_name'
    )
}}

WITH source AS (

  SELECT
    share_type         AS sdo_share_type,
    share_name         AS sdo_share_name,
    object_type        AS sdo_object_type,
    object_name        AS sdo_object_name,
    producer_account   AS sdo_producer_account,
    producer_namespace AS sdo_producer_namespace,
    include_new        AS sdo_include_new
  FROM {{ source('pg_catalog_sc', 'svv_datashare_objects') }}
  {% if target.name == 'dev' %}
  LIMIT 1
  {% endif %}

)

SELECT
  sdo_share_type,
  sdo_share_name,
  sdo_object_type,
  sdo_object_name,
  sdo_producer_account,
  sdo_producer_namespace,
  sdo_include_new
FROM source