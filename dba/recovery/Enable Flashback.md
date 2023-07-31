[toc]

# Enable Flashback

> 물리적 손상(장애나 기타 이유로 디스크나 파일손상)이 아닌
> 사용자의 실수나 오류로 인해 데이터에만 문제가 있는 경우 빠르게 복구하도록 만든 기능
>
> FLASHBACK => 과거를 불러오는 행위 (=> 모든 과거를 보관하고있어야함 =>  infinity accumulation)

## 사전 준비

### archive log

#### 1. select

##### archive log 정보

```sql
SQL> archive log list
Database log mode              No Archive Mode
Automatic archival             Disabled
Archive destination            /oracle12/app/oracle/product/12.2.0.1/db_1/dbs/arch
Oldest online log sequence     202
Current log sequence           204
```

##### 파라미터를 통한 기타 정보

```sql
select *
  from v$parameter
 where name in ('db_recovery_file_dest',
                'db_recovery_file_size',
                'log_archive_dest_1');

{[
	{
		"NUM" : 1664,
		"NAME" : "log_archive_dest_1",
		"TYPE" : 2,
		"VALUE" : null,
		"DISPLAY_VALUE" : null,
		"DEFAULT_VALUE" : "NONE",
		"ISDEFAULT" : "TRUE",
		"ISSES_MODIFIABLE" : "TRUE",
		"ISSYS_MODIFIABLE" : "IMMEDIATE",
		"ISPDB_MODIFIABLE" : "FALSE",
		"ISINSTANCE_MODIFIABLE" : "TRUE",
		"ISMODIFIED" : "FALSE",
		"ISADJUSTED" : "FALSE",
		"ISDEPRECATED" : "FALSE",
		"ISBASIC" : "TRUE",
		"DESCRIPTION" : "archival destination #1 text string",
		"UPDATE_COMMENT" : null,
		"HASH" : 2668113655,
		"CON_ID" : 0
	},
	{
		"NUM" : 1873,
		"NAME" : "db_recovery_file_dest",
		"TYPE" : 2,
		"VALUE" : null,
		"DISPLAY_VALUE" : null,
		"DEFAULT_VALUE" : "NONE",
		"ISDEFAULT" : "TRUE",
		"ISSES_MODIFIABLE" : "FALSE",
		"ISSYS_MODIFIABLE" : "IMMEDIATE",
		"ISPDB_MODIFIABLE" : "FALSE",
		"ISINSTANCE_MODIFIABLE" : "FALSE",
		"ISMODIFIED" : "FALSE",
		"ISADJUSTED" : "FALSE",
		"ISDEPRECATED" : "FALSE",
		"ISBASIC" : "TRUE",
		"DESCRIPTION" : "default database recovery file location",
		"UPDATE_COMMENT" : null,
		"HASH" : 3387568471,
		"CON_ID" : 0
	}
]}
```

#### 2. enable

> online중 불가, mount단계로 이동

```sql
SQL> shutdown immediate;
SQL> startup mount;
SQL> alter database archivelog;
SQL> alter database open;

SQL> archive log list
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            /oracle12/app/oracle/product/12.2.0.1/db_1/dbs/arch
Oldest online log sequence     202
Next log sequence to archive   204
Current log sequence           20445674gvb8956789676
```

### flashback

#### 1. select

```sql
SQL> select flashback_on from v$database;

FLASHBACK_ON
------------------
NO
```

#### 2. enable

```sql
alter system set db_recovery_file_dest_size=5g scope=spfile;
alter system set db_recovery_file_dest='/oracle12/archive' scope=spfile;
SQL> !mkdir '/oracle12/archive'
```

```sql
SQL> shutdown immediate;
SQL> startup;

SQL> alter database flashback on;

Database altered.

SQL> select flashback_on from v$database;

FLASHBACK_ON
------------------
YES
```

#### 3. alter dest path

```sql
shutdown immediate;
startup;
alter database flashback on;

alter system set db_recovery_file_dest_size=5g scope=spfile;
alter system set db_recovery_file_dest='/home/oracle/archive' scope=spfile;
alter system set log_archive_dest_1='location=/home/oracle/archive' scope=spfile;
```



### flashback parameter

| key                        | value                                    | scope         |
| -------------------------- | ---------------------------------------- | ------------- |
| db_recovery_file_dest_size | bytes(ex: `2g`)                          | pfile\|spfile |
| db_recovery_file_dest      | physical path(ex: `'/oracle12/archive'`) | pfile\|spfile |

