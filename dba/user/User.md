[toc]

# User

## Schema

- 특정 사용자가 생성한 object 의 집합을 의미
- user가 생성될 때 관련 schema가 생성됨.
- user와 schema를 혼용해서 사용하기도 함.

## Schema Object

- Tables
- Indexes
- Views
- Triggers 
- Constraints 
- Database links 
- Synonyms 
- Stored Procedures 
- Sequences

## Manage

### create

```sql
create user tuser identified by oracle
default tablespace users
temporary tablespace temp
quota unlimited on users
quota 100m on users2
profile default
;
```

### grant

```sql
grant create session to tuser;
```

### select

```sql
select username,
			 account_status,						-- 계정 상태
			 lock_date,
			 expiry_date,
			 default_tablespace,
			 temporary_tablespace,
			 profile
  from dba_users
 where 1=1
   and username = 'TUSER'
;

select *
  from dba_ts_quotas
 where 1=1
   and username = 'TUSER';
```

### alter user

#### 1. profile

```sql
alter user tuser profile profile1;
```

#### 2. lock/unlock

```sql
alter user tuser account unlock;
alter user tuser account lock;
```

#### 3. password

```sql
alter user tuser identified by test;
```

### SESSION

#### 1. select

```sql
SELECT DISTINCT
       A.INST_ID
      ,A.USERNAME
      ,X.SESSION_ID
      ,A.SERIAL#
      ,A.STATUS
      ,D.OBJECT_NAME
      ,A.MACHINE
      ,A.OSUSER
      ,A.TERMINAL
      ,A.CLIENT_INFO
      ,A.PROGRAM
      ,A.LOGON_TIME
      ,A.PREV_EXEC_START
      ,S.SQL_TEXT
      ,'ALTER SYSTEM KILL SESSION ''' || A.SID || ', ' || A.SERIAL# || ''';'
  FROM GV$LOCKED_OBJECT X
      ,GV$SESSION A
      ,DBA_OBJECTS D
      ,GV$SQLAREA S
 WHERE X.SESSION_ID=A.SID
   AND X.OBJECT_ID=D.OBJECT_ID
   AND A.SQL_ID = S.SQL_ID(+)
--   AND D.OBJECT_NAME = ''
 ORDER BY LOGON_TIME;
```

#### 2. kill

```sql
ALTER SYSTEM KILL SESSION '52, 51034';
```
