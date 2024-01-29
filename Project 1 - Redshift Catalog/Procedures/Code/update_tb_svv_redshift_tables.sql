CREATE OR REPLACE PROCEDURE "admin".update_tb_svv_redshift_tables()
	LANGUAGE plpgsql
AS $$
	                                                                                                                                                                                                                              
DECLARE                                                                                                                                                                                                                            
  list record;                                                                                                                                                                                                                     
  table_name varchar(max) := 'admin.tb_svv_redshift_tables';                                                                                                                                                                           
  command1 varchar(max) = 'SELECT database_name, schema_name, table_name, table_type, COALESCE(remarks, ''x'') AS remarks FROM svv_redshift_tables';       
  tmp varchar(max) := 'INSERT INTO ' || table_name || ' VALUES ';                                                                                                                                                                  
  tmp2 varchar(max) = '';                                                                                                                                                                                                          
  stmt varchar(max) := '';                                                                                                                                                                                                         
  counter int := 0;                                                                                                                                                                                                                
  count_table int;                                                                                                                                                                                                                 
BEGIN	                                                                                                                                                                                                                           
  SELECT COUNT(1) INTO count_table FROM svv_redshift_tables;                                                                                                                                                                      
  --EXECUTE 'TRUNCATE TABLE ' || table_name;                                                                                                                                                                                         
  FOR list IN EXECUTE command1 LOOP                                                                                                                                                                                                
    tmp2 := tmp2 || '(' || quote_literal(list.database_name::varchar)                                                                                                                                                              
                 || ',' || quote_literal(list.schema_name::varchar)                                                                                                                                                                
                 || ',' || quote_literal(list.table_name::varchar)       
                 || ',' || quote_literal(list.table_type::varchar)    
                 || ',' || quote_literal(list.remarks::varchar)    
                 || '), ';                                                                                                                                                                                                         
    counter := counter + 1;                                                                                                                                                                                                        
    IF counter % 200 = 0 OR counter = count_table THEN                                                                                                                                                                             
      tmp2 := rtrim(tmp2, ', ');                                                                                                                                                                                                   
      stmt := tmp || tmp2;                                                                                                                                                                                                         
      RAISE INFO '% rows were loaded.', counter;                                                                                                                                                                            
	  IF tmp2 <> '' THEN                                                                                                                                                                                                           
        EXECUTE stmt;                                                                                                                                                                                                              
      END IF;                                                                                                                                                                                                                      
      tmp2 := '';                                                                                                                                                                                                                  
    END IF;                                                                                                                                                                                                                        
  END LOOP;                                                                                                                                                                                                                        
END;                                                                                                                                                                                                                               

$$
;