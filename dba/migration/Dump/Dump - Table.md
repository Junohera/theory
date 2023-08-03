[toc]

# Dump - Table

## 사전 준비

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

참고) 테이블 건수 조회 속도

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

실습

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

이관 현황 확인

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

-- 4. 유저별, 인덱스별 할당 사이즈
select i.owner,
       i.index_name,
       s.bytes/1024/1024 as "size(mb)"
  from dba_indexes i
  left outer join dba_segments s
    on i.owner = s.owner and i.index_name = s.segment_name
 where 1=1
   and i.tablespace_name not in ('SYSTEM', 'SYSAUX')
 order by i.owner, "size(mb)" desc;
   
-- 빈 INDEX가 생기는 경우(빈테이블에 생성시 데이터가 아직 없으므로 index에 segment를 할당하지 않음)
create table scott.deferred_segment_creation(no number, name varchar2(10));
create index scott.idx_deferred_segment_creation on scott.deferred_segment_creation(no);

select * from dba_indexes where index_name = 'IDX_DEFERRED_SEGMENT_CREATION';
select * from dba_segments where segment_name = 'IDX_DEFERRED_SEGMENT_CREATION';
```

