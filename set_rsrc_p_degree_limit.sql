BEGIN

    dbms_resource_manager.clear_pending_area;
    dbms_resource_manager.create_pending_area;

    dbms_resource_manager.update_plan_directive
      ( plan                            =>  'PERF_PLAN',
        group_or_subplan                =>  'ETL',
        new_parallel_degree_limit_p1    =>  64
      );

    dbms_resource_manager.update_plan_directive
      ( plan                            =>  'PERF_PLAN',
        group_or_subplan                =>  'MAINTENANCE',
        new_parallel_degree_limit_p1    =>  64
      );

    dbms_resource_manager.update_plan_directive
      ( plan                            =>  'PERF_PLAN',
        group_or_subplan                =>  'OTHER_GROUPS',
        new_parallel_degree_limit_p1    =>  64
      );

    dbms_resource_manager.update_plan_directive
      ( plan                            =>  'PERF_PLAN',
        group_or_subplan                =>  'QUERYHIGH',
        new_parallel_degree_limit_p1    =>  64
      );

    dbms_resource_manager.update_plan_directive
      ( plan                            =>  'PERF_PLAN',
        group_or_subplan                =>  'QUERYLOW',
        new_parallel_degree_limit_p1    =>  64
      );

    dbms_resource_manager.update_plan_directive
      ( plan                            =>  'PERF_PLAN',
        group_or_subplan                =>  'SYS_GROUP',
        new_parallel_degree_limit_p1    =>  64
      );
    
    dbms_resource_manager.validate_pending_area;
    dbms_resource_manager.submit_pending_area;

END;
/
