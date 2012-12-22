set echo on
alter session set "_serial_direct_read"=always;
alter session set cell_offload_processing=true;
set echo off
