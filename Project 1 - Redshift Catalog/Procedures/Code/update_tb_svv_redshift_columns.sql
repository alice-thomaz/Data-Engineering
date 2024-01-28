CREATE OR REPLACE PROCEDURE "admin".update_tb_svv_redshift_columns()
	LANGUAGE plpgsql
AS $$
	
DECLARE
  list record;
  table_name varchar(max) := 'admin.tb_svv_redshift_columns';
  command1 varchar(max) = 'SELECT database_name, schema_name, table_name, column_name, ordinal_position, data_type, is_nullable, encoding, distkey, sortkey, COALESCE(remarks, ''x'') as remarks FROM svv_redshift_columns';
  tmp varchar(max) := 'INSERT INTO ' || table_name || ' VALUES ';
  tmp2 varchar(max) = '';
  stmt varchar(max) := '';
  counter int := 0;
  count_table int;
BEGIN	
  SELECT COUNT(1) INTO count_table FROM svv_redshift_columns;
  EXECUTE 'TRUNCATE TABLE ' || table_name;
  FOR list IN EXECUTE command1 LOOP
    tmp2 := tmp2 || '(' || quote_literal(list.database_name::VARCHAR)
                 || ',' || quote_literal(list.schema_name::VARCHAR)
                 || ',' || quote_literal(list.table_name::VARCHAR)
                 || ',' || quote_literal(list.column_name::VARCHAR)
                 || ',' || quote_literal(list.ordinal_position::INTEGER)
                 || ',' || quote_literal(list.data_type::VARCHAR)
                 || ',' || quote_literal(list.is_nullable::VARCHAR)
                 || ',' || quote_literal(list."encoding"::VARCHAR)
                 || ',' || CASE WHEN list.distkey = true THEN 1 ELSE 0 END
                 || ',' || quote_literal(list."sortkey"::INTEGER)
                 || ',' || quote_literal(list.remarks::VARCHAR)
                 || '), ';
    counter := counter + 1;
    IF counter % 200 = 0 OR counter = count_table THEN
      tmp2 := rtrim(tmp2, ', ');
      stmt := tmp || tmp2;
      RAISE INFO 'Foram carregadas % linhas.', counter;
	  IF tmp2 <> '' THEN
        EXECUTE stmt;
      END IF;
      tmp2 := '';
    END IF;
  END LOOP;
END;

$$
;