CREATE TABLE IF NOT EXISTS "admin".tb_svv_redshift_columns

(

	database_name VARCHAR(255)   ENCODE lzo
	,schema_name VARCHAR(255)   ENCODE lzo
	,table_name VARCHAR(255)   ENCODE lzo
	,column_name VARCHAR(255)   ENCODE lzo
	,ordinal_position INTEGER   ENCODE az64
	,data_type VARCHAR(255)   ENCODE lzo
	,is_nullable VARCHAR(255)   ENCODE lzo
	,"encoding" VARCHAR(255)   ENCODE lzo
	,"distkey" INTEGER   ENCODE az64
	,"sortkey" INTEGER   ENCODE az64
	,remarks VARCHAR(4096)   ENCODE lzo
  
)