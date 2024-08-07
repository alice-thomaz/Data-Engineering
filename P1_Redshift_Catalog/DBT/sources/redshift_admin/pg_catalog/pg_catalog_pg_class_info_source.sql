{{
  config(
    materialized = 'table',
    dist = 'pci_reloid',
    sort = 'pci_relcreationtime'
    )
}}

WITH source AS(  

    SELECT 
      reloid::INT                  AS pci_reloid,
      relname::VARCHAR(255)        AS pci_relname,                
      relnamespace::INT            AS pci_relnamespace,
      relcreationtime::TIMESTAMP   AS pci_relcreationtime
    FROM {{ source('pg_catalog_sc', 'pg_class_info') }}
    WHERE relcreationtime IS NOT NULL
    {% if target.name == 'dev' %}
    LIMIT 1
    {% endif %}

)

SELECT 
  pci_reloid,
  pci_relname,
  pci_relnamespace,
  pci_relcreationtime
FROM source