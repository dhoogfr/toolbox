create tablespace test_small
datafile 'c:\oracle\oradata\vdev1\test\test_small01.dbf'
size 71744K
extent management local uniform size 64K
/

create tablespace test_medium
datafile 'c:\oracle\oradata\vdev1\test\test_medium01.dbf'
size 102464K
extent management local uniform size 512K
/

create tablespace tools_small
datafile 'c:\oracle\oradata\vdev1\tools\tools_small01.dbf'
size 71744K
extent management local uniform size 64K
/

create tablespace tools_medium
datafile 'c:\oracle\oradata\vdev1\tools\tools_medium01.dbf'
size 102464K
extent management local uniform size 512K
/
