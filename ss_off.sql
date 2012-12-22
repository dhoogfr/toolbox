alter session set "_serial_direct_read"=always;
set echo on
alter session set cell_offload_processing=false;
alter session set "_kcfis_storageidx_disabled"=true;
set echo off
