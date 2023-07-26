[toc]

# Begin backup

## flow

> 테이블스페이스별로 begin -> copy -> end
>
> 예를들어 3개의 테이블스페이스를 백업한다고 가정하면
>
> 1. tablespace A begin -> copy -> end
> 4. tablespace B begin -> copy -> end
> 7. tablespace C begin -> copy -> end
> 10. ...

1. begin backup
2. physical backup
3. end backup
4. backup controlfile

## commands

### 1. datafile 조회

```sql
select tablespace_name,
			 file_name,
			 bytes/1024/1024 as "size(MB)"
  from dba_data_files;
```

### 2. begin backup mode

```sql
alter tablespace ${TABLESPACE_NAME} begin backup;
```

### 3. end backup mode

```sql
alter tablespace ${TABLESPACE_NAME} end backup;
```

### 4. backup status 조회

```sql
select a.file#,
       a.name,
       b.status,
       to_char(b.time, 'YYYY-MM-DD:HH24:MI:SS') as time
  from v$datafile a,
       v$backup b
 where a.file#=b.file#;
```

### 5. backup controlfile

```sql
alter database backup controlfile to trace as '/opt/backup4oracle12/backup/control.sql';
```

## all in one

```sql
with
  CONSTANTS as (
    select (select '/opt/backup4oracle12/online/backup_'||to_char(sysdate, 'YYYYMMDD')||'/' as value from dual) as PATH,
           (select 'oracle:oinstall' from dual) as WHO
      from dual
  ),
  TARGET_TABLESPACES as (
    select tablespace_name
      from dba_tablespaces
     where tablespace_name not like 'TEMP%'
  ),
  OPEN_CLOSE as (
    select 'mkdir -p '||(select PATH from CONSTANTS) as mkdir_command,
           'chown -R '||(select WHO from CONSTANTS)||' '||(select PATH from CONSTANTS) as chown_command
      from dual
  ),
  BODY_BEGIN_BACKUP as (
    select tablespace_name,
           'alter tablespace '||tablespace_name||' begin backup;' as begin_query
      from (select tablespace_name
      from dba_tablespaces
     where tablespace_name not like 'TEMP%')
  ),
  BODY_END_BACKUP as (
    select tablespace_name,
           'alter tablespace '||tablespace_name||' end backup;' as end_query
      from TARGET_TABLESPACES
  ),
  BODY_PHYSICAL_COPY as (
    select tablespace_name as tablespace_name, 
           'cp '||FILE_NAME||' '||(select PATH from CONSTANTS) as copy_command
      from dba_data_files
  ),
  RESULT as (
    select (select mkdir_command from OPEN_CLOSE) as open_close, null as name, null as begin_query, null as copy, null as end_query
      from dual
     union all
    select null,
           b.tablespace_name,
           b.begin_query,
           null,
           e.end_query
      from BODY_BEGIN_BACKUP b,
           BODY_END_BACKUP e
     where b.tablespace_name = e.tablespace_name
     union all
    select null, tablespace_name, null, copy_command, null
      from BODY_PHYSICAL_COPY
     union all
    select 'alter database backup controlfile to trace as '''||(select PATH from CONSTANTS)||'control.sql'';', null, null, null, null
      from dual
     union all
    select (select chown_command from OPEN_CLOSE), null, null, null, null
      from dual
  )
select *
  from result;
```

```sql
|OPEN_CLOSE    |NAME    |BEGIN_QUERY         |COPY                                                            |END_QUERY           |
|--------------|--------|--------------------|----------------------------------------------------------------|--------------------|
|mkdir -p / ...|        |                    |                                                                |                    |
|              |SYSTEM  |alter tablespace ...|cp /oracle12/app/oracle/oradata/db1/system01.dbf /opt/backup ...|alter tablespace ...|
|              |SYSAUX  |alter tablespace ...|cp /oracle12/app/oracle/oradata/db1/sysaux01.dbf /opt/backup ...|alter tablespace ...|
|              |UNDOTBS1|alter tablespace ...|cp /oracle12/app/oracle/oradata/db1/undotbs01.dbf /opt/backu ...|alter tablespace ...|
|              |USERS   |alter tablespace ...|cp /oracle12/app/oracle/oradata/db1/users01.dbf /opt/backup4 ...|alter tablespace ...|
|              |USERS   |alter tablespace ...|cp /oracle12/app/oracle/oradata/db1/users02.dbf /opt/backup4 ...|alter tablespace ...|
|alter data ...|        |                    |                                                                |                    |
|chown -R o ...|        |                    |                                                                |                    |
```

