accept l_source_db char prompt 'Source database name: '
accept l_dest_db char prompt 'Target database name: '

set verify off

DECLARE

  l_source_str       varchar2(30) := '(.*)&l_source_db.(.*)';  
  l_replace_str      varchar2(30) := '\1&l_dest_db.\2';
  
BEGIN

  for job_class in
    ( select
        owner || '.' || job_class_name as name,
        service,
        regexp_replace(service, l_source_str, l_replace_str) new_service
      from
        dba_scheduler_job_classes
      where
        service is not null
    )
  loop
  
    dbms_output.put_line('job_class ' || job_class.name || ' old service name: ' || job_class.service || ' new service name ' || job_class.new_service);
    
    dbms_scheduler.set_attribute
      ( name        =>  job_class.name,
        attribute   =>  'service',
        value       =>  job_class.new_service
      );

   end loop;
 
END;
/
