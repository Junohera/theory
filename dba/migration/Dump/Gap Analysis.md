[toc]

# Gap Analysis

ASIS DB와 TOBE DB의 오브젝트 비교하기 위한 개념
주로 DB 이관(MIGRATION) 작업시 수행하고
정상적으로 이관이 되었는지를 비교하기 위함

## 분석 대상

### target_view

- dba_users
- dba_tables
- dba_tab_columns
- dba_indexes
- dba_ind_columns

### logical_target

- 테이블
  - 이름
  - 컬럼이름
  - 컬럼순서
  - 컬럼 타입 및  사이즈
  - 널허용 여부
- 인덱스
  - 이름
  - 컬럼이름
  - 컬럼순서
  - 정렬

## 사전 환경조성

### 0. CLEAR(💙,💚)

#### tablespace

```sql
select 'drop tablespace ' || tablespace_name || ' including contents and datafiles;' as command
  from dba_tablespaces
 where tablespace_name not in ('SYSTEM', 'SYSAUX', 'USERS')
   and tablespace_name not like 'UNDO%'
   and tablespace_name not like 'TEMP%';
```

#### user

```sql
select 'drop user '||username||' cascade;' as command
  from dba_users
 where username like 'TEST%'
    or username like 'TUSER%'
    or username in ('HR', 'TBS');
```

#### table

```sql
select 'drop table '||owner||'.'||table_name||' purge;' as command
  from dba_tables
 where owner in ('SYSTEM', 'SCOTT')
   and table_name not like '%$%'
   and table_name not like 'LOGMNR%'
   and table_name not like 'REDO%'
   and table_name not like 'SCHEDULER%'
   and table_name not like 'SQLPLUS%'
   and table_name not like 'HELP%'
   and table_name not in ('EMP', 'DEPT');
```

### 1. TARGET DB_DBLINK(💙)

```sql
select * from dba_db_links where owner <> 'SYS';
|OWNER |DB_LINK|USERNAME|HOST     |CREATED                |HIDDEN|
|------|-------|--------|---------|-----------------------|------|
|PUBLIC|GREEN  |SYSTEM  |GREEN_DB1|2023-07-27 13:52:49.000|NO    |
```

### 2. DBLINK TEST(💙)

```sql
select * from dba_users@green;
```

### 3. 신규 OBJECT

```sql
💙,💚
drop table scott.t1 purge;
drop table scott.t2 purge;
drop table scott.t3 purge;
drop table scott.t4 purge;
drop table scott.t5 purge;
drop table scott.t6 purge;
drop table scott.t7 purge;
drop table scott.t8 purge;

create table scott.t1(no number, name varchar2(10), addr varchar2(50));
create table scott.t2(no number, name varchar2(10), addr varchar2(50));
create table scott.t7(no number, name varchar2(10), addr varchar2(50));
create table scott.t8(no number);
create index scott.IDX_T7_NAME_ADDR on scott.t7(name, addr);

💙
create table scott.t3(no number, name varchar2(10), addr varchar2(50));
create table scott.t5(no number, name varchar2(10), addr varchar2(50));
create table scott.t6(no number, name varchar2(10), addr varchar2(50));
alter table scott.t7 add constraint PK_T7_NO primary key (no);
create index scott.IDX_T7_NAME on scott.t7(name);
alter table scott.t8 add name varchar2(20) not null;
alter table scott.t8 add addr varchar2(50) not null;

💚
create table scott.t4(no number, name varchar2(10), addr varchar2(50));
create table scott.t5(no number, name varchar2(10));
create table scott.t6(no varchar(4), name varchar2(10), addr varchar2(50));
alter table scott.t6 add constraint PK_T6_NO primary key (no);
create index scott.IDX_T7_ADDR_NAME on scott.t7(addr, name);
alter table scott.t8 add addr varchar2(50);
alter table scott.t8 add name varchar2(10);
```

---

## Query

```sql
/*
 CASE1) GAP ANALYSIS - TABLENAME
*/ 

with 
CONSTANT as (
  select 'SCOTT' as target_owner 
    from dual 
),
IGNORE_TABLE as (
  select 'EMP' from dual
   union all 
  select 'DEPT' from dual
),
BLUE_TABLE as (
  select t.owner,
         t.table_name,
         t.tablespace_name
    from dba_tables t
   where t.owner = (select target_owner from constant)
     and t.table_name not in (select * from IGNORE_TABLE)
     and t.table_name not like 'BIN%'
),
GREEN_TABLE as (
  select t.owner,
         t.table_name,
         t.tablespace_name
    from dba_tables@green t
   where t.owner = (select target_owner from constant)
     and t.table_name not in (select * from IGNORE_TABLE)
     and t.table_name not like 'BIN%'
),
GAP_TABLE as (
  select 'TABLE' as CATEGORY,
         '' as reason,
         nvl(b.owner, g.owner) as owner,
         nvl(b.table_name, g.table_name) as table_name,
         b.table_name as "table_name(A)", g.table_name as "table_name(B)"
    from blue_table b
    full outer join green_table g
      on b.owner = g.owner
     and b.tablespace_name = g.tablespace_name
     and b.table_name = g.table_name
   where b.table_name is null 
      or g.table_name is null
),
BLUE_COLUMN as (
  select t.owner,
         t.table_name,
         c.column_name,
         c.data_type,
         c.data_length,
         c.nullable,
         c.data_precision,
         c.data_scale,
         c.column_id
    from blue_table t
    left outer join dba_tab_columns c
      on t.owner = c.owner
     and t.table_name = c.table_name
),
GREEN_COLUMN as (
  select t.owner,
         t.table_name,
         c.column_name,
         c.data_type,
         c.data_length,
         c.nullable,
         c.data_precision,
         c.data_scale,
         c.column_id
    from green_table t
    left outer join dba_tab_columns@green c
      on t.owner = c.owner
     and t.table_name = c.table_name
),
GAP_COLUMN_TYPE as (
  select 'COLUMN(TYPE)' as CATEGORY,
         'missing column: '||(case when b.column_name is null or g.column_name is null then '✅' else '' end)
         ||CHR(10)||'data_type: '||(case when b.data_type <> g.data_type then '✅' else '' end)
         ||CHR(10)||'data_length: '||(case when b.data_length <> g.data_length then '✅' else '' end)
         ||CHR(10)||'nullable '||(case when b.nullable <> g.nullable then '✅' else '' end)
         ||CHR(10)||'data_precision: '||(case when b.data_precision <> g.data_precision then '✅' else '' end)
         ||CHR(10)||'data_scale: '||(case when b.data_scale <> g.data_scale then '✅' else '' end)         
         as reason,
         b.owner as "owner(A)", g.owner as "owner(B)",
         b.table_name as "table_name(A)", g.table_name as "table_name(B)",
         b.column_name as "column_name(A)", g.column_name as "column_name(B)",
         b.data_type as "data_type(A)", g.data_type as "data_type(B)",
         b.data_length as "data_length(A)", g.data_length as "data_length(B)",
         b.nullable as "nullable(A)", g.nullable as "nullable(B)",
         b.data_precision as "data_precision(A)", g.data_precision as "data_precision(B)",
         b.data_scale as "data_scale(A)", g.data_scale as "data_scale(B)",
         b.column_id as "column_id(A)", g.column_id as "column_id(B)"
    from BLUE_COLUMN b
    full outer join GREEN_COLUMN g
      on b.owner = g.owner
     and b.table_name = g.table_name
     and b.column_name = g.column_name
   where (b.column_name is null or g.column_name is null)
      or (b.data_type <> g.data_type)
      or (b.data_length <> g.data_length)
      or (b.nullable <> g.nullable)
      or (b.data_precision <> g.data_precision)
      or (b.data_scale <> g.data_scale)
),
GAP_COLUMN_ORDER as (
  select 'COLUMN(ORDER)' as CATEGORY,
         'diff order('||b.column_id||':'||g.column_id||')' as reason,
         b.owner as "owner(A)", g.owner as "owner(B)",
         b.table_name as "table_name(A)", g.table_name as "table_name(B)",
         b.column_name as "column_name(A)", g.column_name as "column_name(B)",
         b.data_type as "data_type(A)", g.data_type as "data_type(B)",
         b.data_length as "data_length(A)", g.data_length as "data_length(B)",
         b.nullable as "nullable(A)", g.nullable as "nullable(B)",
         b.data_precision as "data_precision(A)", g.data_precision as "data_precision(B)",
         b.data_scale as "data_scale(A)", g.data_scale as "data_scale(B)",
         b.column_id as "column_id(A)", g.column_id as "column_id(B)"
    from BLUE_COLUMN b
    full outer join GREEN_COLUMN g
      on b.owner = g.owner
     and b.table_name = g.table_name
     and b.column_name = g.column_name
   where cast(b.column_id as varchar2(3)) <> cast(g.column_id as varchar2(3))
),
GAP_COLUMN as (
  select category,
         reason,
         nvl("owner(A)","owner(B)") as owner,
         nvl("table_name(A)","table_name(B)") as table_name,
         nvl("column_name(A)","column_name(B)") as column_name,
         t."data_type(A)", t."data_type(B)",
         t."data_length(A)", t."data_length(B)",
         t."nullable(A)", t."nullable(B)",
         t."data_precision(A)", t."data_precision(B)",
         t."data_scale(A)", t."data_scale(B)",
         t."column_id(A)", t."column_id(B)"
    from (select * from GAP_COLUMN_TYPE
           union all
          select * from GAP_COLUMN_ORDER) t
),
BLUE_INDEX as (
  select i.owner,
         i.table_name,       
         i.index_name,
         c.column_name,
         i.uniqueness,
         c.descend,
         i.status,
         i.visibility,
         i.segment_created,
         i.indexing,
         i.last_analyzed,
         c.column_position
    from dba_indexes i
    left outer join dba_ind_columns c
      on i.owner = c.index_owner
     and i.index_name = c.index_name
     and i.table_name = c.table_name
   where i.owner = (select target_owner from constant)
     and i.table_name not in (select * from IGNORE_TABLE)
),
GREEN_INDEX as (
  select i.owner,
         i.table_name,       
         i.index_name,
         c.column_name,
         i.uniqueness,
         c.descend,
         i.status,
         i.visibility,
         i.segment_created,
         i.indexing,
         i.last_analyzed,
         c.column_position
    from dba_indexes@green i
    left outer join dba_ind_columns@green c
      on i.owner = c.index_owner
     and i.index_name = c.index_name
     and i.table_name = c.table_name
   where i.owner = (select target_owner from constant)
     and i.table_name not in (select * from IGNORE_TABLE)
),
GAP_INDEX as (
  -- TODO: GAP_INDEX
  select * from GREEN_INDEX
),
GAP_SUMMARY as (
--  select * from gap_table
--  select * from gap_column
  select * from gap_index
--  select * from gap_constraint
)
select *
  from gap_summary;
```

