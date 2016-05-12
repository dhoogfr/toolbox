CREATE GLOBAL TEMPORARY TABLE uptime.plan_table
    (statement_id                   VARCHAR2(30),
    timestamp                      DATE,
    remarks                        VARCHAR2(80),
    operation                      VARCHAR2(30),
    options                        VARCHAR2(255),
    object_node                    VARCHAR2(128),
    object_owner                   VARCHAR2(30),
    object_name                    VARCHAR2(30),
    object_instance                NUMBER(*,0),
    object_type                    VARCHAR2(30),
    optimizer                      VARCHAR2(255),
    search_columns                 NUMBER,
    id                             NUMBER(*,0),
    parent_id                      NUMBER(*,0),
    position                       NUMBER(*,0),
    cost                           NUMBER(*,0),
    cardinality                    NUMBER(*,0),
    bytes                          NUMBER(*,0),
    other_tag                      VARCHAR2(255),
    partition_start                VARCHAR2(255),
    partition_stop                 VARCHAR2(255),
    partition_id                   NUMBER(*,0),
    other                          LONG,
    distribution                   VARCHAR2(30),
    cpu_cost                       NUMBER(*,0),
    io_cost                        NUMBER(*,0),
    temp_space                     NUMBER(*,0),
    access_predicates              VARCHAR2(4000),
    filter_predicates              VARCHAR2(4000))
ON COMMIT PRESERVE ROWS
/

GRANT DELETE ON uptime.plan_table TO public
/
GRANT INSERT ON uptime.plan_table TO public
/
GRANT SELECT ON uptime.plan_table TO public
/
GRANT UPDATE ON uptime.plan_table TO public
/
GRANT REFERENCES ON uptime.plan_table TO public
/
GRANT ON COMMIT REFRESH ON uptime.plan_table TO public
/
GRANT QUERY REWRITE ON uptime.plan_table TO public
/

CREATE PUBLIC SYNONYM plan_table
  FOR uptime.plan_table
/

