DECLARE
    l_job number;

BEGIN

    dbms_job.submit( job => l_job,
                     what => 'BEGIN dbms_stats.gather_schema_stats(ownname => ''ADM'', method_opt => ''FOR ALL INDEXED COLUMNS SIZE 1'', cascade => true); END;',
                     next_date => trunc(sysdate) + 6/24,
                     interval => 'trunc(sysdate) + 30/24'
                   );
END;

