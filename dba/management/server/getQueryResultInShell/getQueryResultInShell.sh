#!/bin/sh

query="
  select to_char(sysdate + level, 'YYYYMMDD HH24:MI:SS') as yyyymmdd
    from dual
  connect by level <= 10;
"
result=$(sqlplus -S scott/oracle <<_eof_
set head off
set feedback off
set pagesize 0
set linesize 1000
$query
_eof_
)

filename=".temp.$(echo $0 | awk -F. '{print $1}')"
echo "$result" > $filename