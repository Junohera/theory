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
select sum(round((blocks*block_size)/1024/1024/1024, 2)) as "TOTAL(GB)"
  from v$archived_log
 where 1=1
--   and completion_time between to_date('2023/07/27 11:50:00', 'YYYY/MM/DD HH24:MI:SS') 
--   and to_date('2023/07/27 12:20:00', 'YYYY/MM/DD HH24:MI:SS')
   and name not like '%worm%'
 order by completion_time desc;
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

### 6. completion_time에 포함하는 archive file 정보 조회

```sql
with 
constants as (
  select prefix||suffix as path,
         start_time,
         end_time
    from (select to_char(sysdate, 'YYYYMMDD_HH24MISS') as suffix,
                 '/opt/backup4oracle12/arch_' as prefix,
                 '2023-07-27 15:38:00' as start_time,
                 '2023-07-27 15:40:11' as end_time
            from dual)
)
select name,
       round((blocks*block_size)/1024/1024, 2) "SIZE(MB)",
       sequence#,
       first_change#,
       next_change#,
       completion_time
  from v$archived_log
 where 1=1
   and completion_time between to_date((select start_time from constants), 'YYYY/MM/DD HH24:MI:SS') 
   and to_date((select end_time from constants), 'YYYY/MM/DD HH24:MI:SS')
   and name not like '%worm%'
 order by completion_time desc;
 
|NAME                                 |SIZE(MB)|SEQUENCE#|FIRST_CHANGE#|NEXT_CHANGE#|COMPLETION_TIME        |
|-------------------------------------|--------|---------|-------------|------------|-----------------------|
|/home/oracle/arch/1_21_1143227339.dbf|0       |21       |1,656,634    |1,656,637   |2023-07-27 15:40:01.000|
|/home/oracle/arch/1_20_1143227339.dbf|0       |20       |1,656,631    |1,656,634   |2023-07-27 15:39:59.000|
|/home/oracle/arch/1_19_1143227339.dbf|0       |19       |1,656,628    |1,656,631   |2023-07-27 15:39:58.000|
|/home/oracle/arch/1_18_1143227339.dbf|0       |18       |1,656,622    |1,656,628   |2023-07-27 15:39:54.000|
|/home/oracle/arch/1_17_1143227339.dbf|0       |17       |1,656,618    |1,656,622   |2023-07-27 15:39:42.000|
|/home/oracle/arch/1_16_1143227339.dbf|0       |16       |1,656,615    |1,656,618   |2023-07-27 15:39:38.000|
|/home/oracle/arch/1_15_1143227339.dbf|0       |15       |1,656,601    |1,656,615   |2023-07-27 15:39:36.000|
|/home/oracle/arch/1_14_1143227339.dbf|0       |14       |1,656,585    |1,656,601   |2023-07-27 15:39:29.000|
|/home/oracle/arch/1_13_1143227339.dbf|0       |13       |1,656,581    |1,656,585   |2023-07-27 15:38:47.000|
|/home/oracle/arch/1_12_1143227339.dbf|4.83    |12       |1,648,932    |1,656,581   |2023-07-27 15:38:45.000|
```

### 7. completion_time에 포함하는 archive file 추출 및 커맨드 조회

```sql
with 
constants as (
  select prefix||suffix as path,
         start_time,
         end_time
    from (select to_char(sysdate, 'YYYYMMDD_HH24MISS') as suffix,
                 '/opt/backup4oracle12/arch_' as prefix,
                 '2023-07-27 15:38:00' as start_time,
                 '2023-07-27 15:40:11' as end_time
            from dual)
)
select 'mkdir -p '||(select path from constants) as commands
  from dual
 union all
select *
  from (select 'cp ' || name ||' '||(select path from constants)
          from v$archived_log
         where 1=1
           and completion_time between to_date((select start_time from constants), 'YYYY/MM/DD HH24:MI:SS') 
           and to_date((select end_time from constants), 'YYYY/MM/DD HH24:MI:SS')
           and name not like '%worm%'
         order by completion_time desc)
 union all
select 'echo '||''''||'TARGET DIRECTORY IS '||(select path from constants)||''''
  from dual
 union all
select 'ls '||(select path from constants)||' | wc -l'
  from dual;
  
|COMMANDS                                                                          |
|----------------------------------------------------------------------------------|
|mkdir -p /opt/backup4oracle12/arch_20230727_173124                                |
|cp /home/oracle/arch/1_21_1143227339.dbf /opt/backup4oracle12/arch_20230727_173124|
|cp /home/oracle/arch/1_20_1143227339.dbf /opt/backup4oracle12/arch_20230727_173124|
|cp /home/oracle/arch/1_19_1143227339.dbf /opt/backup4oracle12/arch_20230727_173124|
|echo 'TARGET DIRECTORY IS /opt/backup4oracle12/arch_20230727_173124'              |
|ls /opt/backup4oracle12/arch_20230727_173124 | wc -l                              |
```

### 8. check archive log file

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

### 9. ?

```sql
select file#,
       change#
  from v$recover_file;
```



## example

### 

## TODO: admin sql