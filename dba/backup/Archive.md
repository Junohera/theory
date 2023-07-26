[toc]

# Archive

## 변경

#### to archive log mode

```sql
startup mount;
alter database archivelog;
alter database open;
```

##### archive 위치 변경 후 DB 재기동

```sql
!mkdir -p /home/oracle/arch
alter system set log_archive_dest_1='location=/home/oracle/arch' scope=spfile;

shutdown immediate;
startup;
```

##### archive 상태 확인

```sql
SQL> archive log list

Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            /home/oracle/arch
...
```

##### datafile 구성 확인

```sql
select * from v$controlfile;
select * from v$logfile;
select * from v$datafile;
select * from dba_data_files;
select * from dba_tablespaces;
```

#### to noarchive log mode

```sql
startup mount;
alter database noarchivelog;
alter database open;
archive log list;
alter database open;
```

## 조회

### 1. archive size by time

```sql
select name,
       round((blocks*block_size)/1024/1024, 2) "SIZE(MB)",
       completion_time
  from v$archived_log
 where 1=1
--   and to_char(completion_time, 'MM/DD/YYYY HH24:MI:SS') between '04/11/2015 00:00:00' and '04/11/2015 23:59:59'
   and name not like '%worm%'
 order by completion_time desc;
```

### 2. archive total size

```sql
select sum(round((blocks*block_size)/1024/1024, 2)) "TOTAL SIZE(MB)"
  from v$archived_log
 where 1=1
--   and to_char(completion_time, 'MM/DD/YYYY HH24:MI:SS') between '04/03/2015 00:00:00' and '04/03/2015 23:59:59'
   and name not like '%worm%';   
```

### 3. archive size by day

```sql
select trunc(first_time, 'dd'),
       to_char(min(first_time), 'dy'),
       round(sum(BLOCKS*block_size)/1024/1024/1024, 2) GB
  from v$archived_log a
 group by trunc(first_time, 'dd')
 order by trunc(first_time, 'dd');
```

### 4. find archive where SCN

```sql
select *
  from v$archived_log
 where first_change# < '1562016'
 order by first_change#;
```

### 5. datafile scn

```sql
select a.name,
       a.checkpoint_change# Datafile_CheckPoint_SCN,
       b.checkpoint_change# Start_SCN,
       c.last_change# Stop_SCN
  from (select name,
               checkpoint_change#
          from v$datafile )a,
       (select name,
               checkpoint_change#
          from v$datafile_header )b,
       (select name,
               last_change#
          from v$datafile )c
 where a.name = b.name
   and b.name = c.name;
|NAME                                          |DATAFILE_CHECKPOINT_SCN|START_SCN|STOP_SCN|
|----------------------------------------------|-----------------------|---------|--------|
|/oracle12/app/oracle/oradata/db1/system01.dbf |909,865                |909,865  |        |
|/oracle12/app/oracle/oradata/db1/sysaux01.dbf |909,865                |909,865  |        |
|/oracle12/app/oracle/oradata/db1/undotbs01.dbf|909,865                |909,865  |        |
|/oracle12/app/oracle/oradata/db1/users01.dbf  |909,865                |909,865  |        |
|/oracle12/app/oracle/oradata/db1/users02.dbf  |909,865                |909,865  |        |
|/oracle12/app/oracle/oradata/db1/test1.dbf    |909,865                |909,865  |        |
```

### 6. ?

```sql
select file#,
       change#
  from v$recover_file;
```

### 7. check archive log file

```sql
set lines 1000
col name format a50
select name,
			 SEQUENCE#,
			 FIRST_CHANGE#,
			 NEXT_CHANGE#
  from v$archived_log
 order by first_change#;
```



## example

### 

## TODO: admin sql