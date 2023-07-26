[toc]

# Recovery Setting

> 리커버리 작업시 prompt상에서 조회해야하는 상황(특히, mount단계)에서 수행해야할 쿼리들을 사전에 준비하기 위함

### bash

```shell
vi ~/.bash_profile

alias "query=clear;cd /oracle12/admin;find . -type f | awk -F/ '{print $NF}' | cat -n"

:wq

query
```

### log_check

```sql
mkdir -p /oracle12/admin

vi log_check.sql

set linesize 100
set pagesize 100
col g format 99
col member format a50
col mb format 9999
col seq# format 999
col status format a8
col arc format a3

select a.group# as G
     , a.member
     , b.bytes/1024/1024 mb
     , b.sequence# "seq#"
     , b.status
     , b.archived arc
  from v$logfile a
     , v$log b
 where a.group# = b.group#
 order by 1, 2;
 
:wq

SQL> @log_check.sql
```

### status

```sql
mkdir -p /oracle12/admin

vi status.sql

select instance_name,
		   status
  from v$instance;

:wq

SQL> @status.sql
```

### archive log file

```sql
vi arch_check.sql

set pagesize 200
set lines 200
col name format a50

select name,
			 SEQUENCE#,
			 FIRST_CHANGE#,
			 NEXT_CHANGE#
  from v$archived_log
 order by first_change#;

:wq

SQL> @arch_check
```

### default undo info

```sql
TODO:
select tablespace_name,
       file_name,
       status,
       autoextensible,
       online_status  
  from dba_data_files
 where tablespace_name = (select value
                            from v$parameter
                           where name = 'undo_tablespace');
 
|TABLESPACE_NAME|FILE_NAME                                     |STATUS   |AUTOEXTENSIBLE|ONLINE_STATUS|
|---------------|----------------------------------------------|---------|--------------|-------------|
|UNDOTBS1       |/oracle12/app/oracle/oradata/db1/undotbs01.dbf|AVAILABLE|YES           |ONLINE       |
```

