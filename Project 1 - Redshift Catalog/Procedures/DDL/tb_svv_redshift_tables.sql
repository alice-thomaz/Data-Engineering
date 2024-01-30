CREATE TABLE IF NOT EXISTS "admin".tb_svv_redshift_tables

(

	database_name VARCHAR(255)   ENCODE lzo
	,schema_name VARCHAR(255)   ENCODE lzo
	,table_name VARCHAR(255)   ENCODE lzo
	,table_type VARCHAR(255)   ENCODE lzo
	,remarks VARCHAR(4096)   ENCODE lzo
  
)