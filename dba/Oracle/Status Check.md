[toc]

# Status Check

## 상태체크

> 로컬에서의 sqlplus가 아닌, 리스너를 통해 접속하여 상태체크해야함.

### listener

```shell
ps -ef | grep lsnr | grep -v grep
```

### pmon

```shell
ps -ef | grep pmon | grep -v grep
```

### like remote connection

|        | listener | available access |
| ------ | -------- | ---------------- |
| local  | O        | ✅                |
| local  | X        | ✅                |
| remote | O        | ✅                |
| remote | X        | ❌                |

#### when listener close, but local

```shell
sqlplus system/oracle  as sysdba -- listener 없어도 실행됨.
```

#### when listener close, but remote

```shell
sqlplus system/oracle@db1 -- listener 있어야만 실행됨
[oracle@oel7 admin]$ sqlplus system/oracle@db1

SQL*Plus: Release 12.2.0.1.0 Production on Fri Jul 28 14:28:23 2023

Copyright (c) 1982, 2016, Oracle.  All rights reserved.

ERROR:
ORA-12541: TNS:no listener
```

---

## 상태체크  shell 작성

```shell
# flow
# 1. pmon process 여부
# 2. lsnr process 여부
# 3. listener를 통해 sqlplus 실행하여 상태와 시간조회 

sqlplus -s /nolog << _EOF_ > /dev/null
conn system/oracle@db1 as sysdba
set head off
set lines 10000
set pages 10000
set feedback off
set echo off
set term off

spool ${PATH}/abc.sh

select instance_name,
       status
  from v$instance;
  
select to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')
  from dual;
/

spool off
_EOF_
```

