[toc]

# Dump - Table

## 사전 준비

### setup undo, temp

```sql
테스트 도중 undo, temp가 없거나 사이즈를 벗어나버리면 오류가 나므로
autoextend를 on처리하자

select *
  from dba_tablespaces;

-- temp file
select tablespace_name,
       file_name,
       bytes/1024/1024 as "size",
       status,
       autoextensible
  from dba_temp_files;
alter database tempfile '/oracle12/app/oracle/oradata/db1/temp02.dbf' autoextend on;

-- data file
select tablespace_name,
       file_name,
       bytes/1024/1024 as "size",
       status,
       online_status,
       autoextensible
  from dba_data_files;
alter database datafile '/oracle12/app/oracle/oradata/db1/undotbs01.dbf' autoextend on;
  
-- 없을 경우,
alter tablespace temp add tempfile '/oracle12/app/oracle/oradata/db1/temp01.dbf' size 20971520  reuse autoextend on next 655360  maxsize 32767m;
```

### test data

```shell
vi test_script.sql

select sysdate from dual;
/

create table scott.test01
( no   number,
  name   varchar2(50),
  address   varchar2(50)
) tablespace   users;
/

begin
for i in 1..10000000 loop
insert into scott.test01
values (i , dbms_random.string('A',49), dbms_random.string('Q',49) );
end loop;
commit;
end ;
/

:wq

SQL> set feedback off
SQL> @test_script
```

#### 참고) 테이블 건수 조회 속도

```sql
select count(*)
  from scott.test01;
TABLE ACCESS (FULL)
Operation	Object	Optimizer	Cost	Cardinality	Bytes
TABLE ACCESS (FULL)	TEST01	[NULL]	42162	8672409	0

  advanced
create index scott.test01_idx1 on scott.test01(no);

select count(no)
  from scott.test01;
INDEX (FAST FULL SCAN)
```

### 덤프

```shell
expdp scott/oracle directory=datapump tables=scott.test01 job_name='FULL'

select sid, serial#, sofar "경과시간(s)",
	   totalwork "총 수행시간(s)", totalwork - sofar "남은시간(s)"
  from v$session_longops
 where opname = 'FULL'
   and sofar != totalwork;
   
select *
  from v$session_longops;
```

### 이관 현황 확인 쿼리를 만들기 위한 snippet

```sql
-- 1. table별 할당 사이즈 조회(dba_segments, dba_tables)
select t.owner,
       t.table_name,
       s.segment_type,
       round(s.bytes/1024/1024, 2) as "size(mb)"
  from dba_tables t
  left outer join dba_segments s
    on t.owner = s.owner and t.table_name = s.segment_name
 where 1=1
   and t.owner in ('SCOTT', 'HR')
 order by "size(mb)" asc;
 
-- 2. extent가 할당되지 않은 빈 테이블 목록(✅ deferred segment creation)
create table scott.deferred_segment_creation(no number);
select owner, table_name 
  from dba_tables
 where owner in ('SCOTT', 'HR')
 minus 
select owner, segment_name
  from dba_segments
 where owner in ('SCOTT', 'HR');
|OWNER|TABLE_NAME               |
|-----|-------------------------|
|SCOTT|DEFERRED_SEGMENT_CREATION|

-- 3. 유저별 할당 사이즈
select u.username, sum(s.bytes)/1024/1024 as "size(mb)"
  from (select username
          from dba_users
         where default_tablespace not in ('SYSTEM', 'SYSAUX')
           and common = 'NO') u
  left outer join (select owner, bytes
                     from dba_segments
                    where 1=1
                      and segment_type = 'INDEX'
                      and tablespace_name not in ('SYSTEM' , 'SYSAUX')) s
    on u.username = s.owner
 where 1=1
 group by u.username;

-- 4. 유저별, 인덱스 할당 사이즈
select i.owner,
       i.index_name,
       s.bytes/1024/1024 as "size(mb)"
  from dba_indexes i
  left outer join dba_segments s
    on i.owner = s.owner and i.index_name = s.segment_name
 where 1=1
   and i.tablespace_name not in ('SYSTEM', 'SYSAUX')
 order by i.owner, "size(mb)" desc;
```

### 이관 현황 확인

```sql
-- ORACLE 
select row_number() over(order by t.owner) as num,
       t.*
  from (select t.owner, 
               t.table_name, 
               count(i.index_name) as 인덱스수,
               nvl(sum(s.bytes)/1024/1024, 0) as "테이블크기(MB)",
               nvl(sum(s2.bytes)/1024/1024, 0) as "인덱스크기(MB)"
          from (select username
                  from dba_users
                 where default_tablespace not in ('SYSTEM', 'SYSAUX')
                   and common = 'NO') u,
               dba_tables t, dba_segments s,
               dba_indexes i, dba_segments s2
         where 1=1
           and u.username = t.owner
           and t.owner = s.owner(+)
           and t.table_name = s.segment_name(+)
           and t.owner = i.owner(+)
           and t.table_name = i.table_name(+)
           and i.index_name = s2.segment_name(+)
         group by t.owner, t.table_name) t;
 
-- ANSI
select row_number() over(order by t.username) as num,
       t.*
  from (select u.username, 
               t.table_name, 
               count(t.table_name) as 테이블수,
               count(i.index_name) as 인덱스수,
               nvl(sum(s.bytes)/1024/1024, 0) as "테이블크기(MB)",
               nvl(sum(s2.bytes)/1024/1024, 0) as "인덱스크기(MB)"
          from (select username
                  from dba_users
                 where default_tablespace not in ('SYSTEM', 'SYSAUX')
                   and common = 'NO') u
          inner join dba_tables t
            on u.username = t.owner
          left outer join dba_segments s
            on t.owner = s.owner
           and t.table_name = s.segment_name
          left outer join dba_indexes i
            on t.owner = i.owner
           and t.table_name = i.table_name
          left outer join dba_segments s2
            on i.index_name = s2.segment_name
         where 1=1
         group by u.username, t.table_name) t;
```

