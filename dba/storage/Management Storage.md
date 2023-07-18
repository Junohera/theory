[toc]

# Management Storage

## 조회

**tablespaces**

```sql
select tablespace_name,
       block_size,                  -- block size(tablespace마다 설정 가능, 권고 X)
       initial_extent,              -- 초기 extent 할당 사이즈
       next_extent,                 -- 다음 extent 할당 사이즈
       extent_management,           -- DMT | LMT
       segment_space_management     -- ASSM | FLM
  from dba_tablespaces;
```

**tables**

```sql
select owner,
       table_name,
       tablespace_name,
       pct_free,
       num_rows,
       blocks,
       last_analyzed
  from dba_tables;
```

**segments**

```sql
select segment_name,
       segment_type,
       segment_subtype,
       tablespace_name,
       bytes/1024/1024 as "SIZE(mb)"
  from dba_segments;
```

**extents**

```sql
select segment_name,
       segment_type,
       extent_id,
       bytes/1024/1024 as "SIZE(mb)",
       blocks
  from dba_extents;
```

### 할당량 수정

```sql
alter user scott quota unlimited on users2;
```

### 테이블스페이스 생성

```sql
create tablespace users3
       datafile '/oracle12/app/oracle/oradata/db1/users04_01.dbf' size 50m
       extent management local				-- 생략시 기본값
       uniform size 1m;								-- extent 할당 크기(initial_extent, next_extent)
       
select * from dba_tablespaces;
```

### 테이블 생성

```sql
create table extent_test1 (
  col1 number
)
pctfree 10
pctused 40							-- ASSM이 비활성화될 경우 사용되어짐.
tablespace users3
storage (
  initial     128K
  next        128K
  minextents  1					-- 생성할 extent 최소 갯수
  maxextents  50				-- 생성할 extent 최대 갯수
  pctincrease 0					-- next값에 대한 증가율
);

select *
  from dba_tables
 where table_name = 'EXTENT_TEST1';
```

### 테이블 정보 조회

> 통계정보를 수집하지 않았기 때문에 보이지 않거나 최신정보와 다를 수 있음.

```sql
select table_name,
       tablespace_name,
       pct_free,
       pct_used,
       initial_extent,
       next_extent,
       num_rows,
       blocks,
       empty_blocks
  from dba_tables
 where table_name = 'STG_TEST1';
```

### 통계정보 갱신

> block / segment size 확인

```sql
analyze table scott.stg_test1 compute statistics;

exec dbms_stats.gather_table_stats('scott', 'PCT_TEST1');
exec dbms_stats.gather_table_stats('scott', 'PCT_TEST2');
```

### DML

```sql
insert into scott.stg_test1 values (1, 'choi', 'aaaaaaaa');
commit;
```

### extent / segment 조회

```sql
select *
  from dba_extents
 where segment_name = 'STG_TEST1';
```

### 대용량 DML

```sql
begin
for i in 1..500000 loop
insert into scott.stg_test1
values(i, dbms_random.string('A', 19), dbms_random.string('Q', 19));
end loop;
commit;
end;
/

-- 통계정보 갱신(block / segment size 확인)
analyze table scott.stg_test1 compute statistics;
-- segment 수,BLOCK 수 확인
select count(*), sum(BLOCKS) from dba_extents where segment_name = 'STG_TEST1';
-- segments들의 총 size 확인
select SEGMENT_NAME,
       sum(BYTES/1024/1024) as "SIZE(MB)"
  from dba_extents 
 where segment_name = 'STG_TEST1'
 group by segment_name;
```

### delete 시도

> 이미 늘어난 extent는 쉽게 줄어들거나 사라지지 않는다
>
> 새로운 데이터를 넣기위한 insert 우선 정책으로 인함.

```sql
delete from scott.stg_test1;
commit;

-- 통계정보 갱신(block / segment size 확인)
analyze table scott.stg_test1 compute statistics;
-- segment 수,BLOCK 수 확인
select count(*), sum(BLOCKS) from dba_extents where segment_name = 'STG_TEST1';
-- segments들의 총 size 확인
select SEGMENT_NAME,
       sum(BYTES/1024/1024) as "SIZE(MB)"
  from dba_extents 
 where segment_name = 'STG_TEST1'
 group by segment_name;
 
--> delete를 수행해도 extent나 block등의 수량은 동일(즉시 free block으로 반환되지 않음)✅
--> 실제 데이터건수와 상관없이 조회성능 악화 발생할 수 있음. -> reorg(보통 1년에 한번)

alter table scott.STG_TEST1 move tablespace USERS2;
```

### reorg💊

>  블럭 재구성

- delete를 해도 freeblock을 반환하지 않아 실제건수 대비 디스크영역이 너무 많아져 성능저하
- 실제 사용하는 건수에 맞게 물리적인 공간을 재배치하여 성능 향상 --> 재구성 필요
- reorg 대상: 해당 테이블의 전체 블럭수와 실사용 블록수의 차이를 확인하면 알 수 있음.

**재구성**
이미 속해있던 동일한 tablespace로 move시키면 실제사용하는 데이터에 맞게 블럭들이 재배치됨

```sql
alter table scott.STG_TEST1 move tablespace USERS2;
```

**할당된 블록수 조회**

```sql
select sum(BLOCKS) as "할당된 블록수"
  from dba_extents
 where segment_name = 'NOLOGGING_TEST';
```

**실사용 블록수 조회**
재구성 전/후로 조회해야할 쿼리

```sql
select count(
         distinct dbms_rowid.rowid_block_number(rowid) || 
         dbms_rowid.rowid_relative_fno(rowid)
       ) as "실사용 블록수" 
  from NOLOGGING_TEST;
```

**할당된 블록수:실사용블록수 조회**

```sql
select a.blocks, 
			 b.blocks,
       a.blocks - b.blocks as gap
  from (select sum(BLOCKS) as blocks
          from dba_extents
         where segment_name = 'NOLOGGING_TEST'
       ) a,
       (select count(distinct dbms_rowid.rowid_block_number(rowid) || dbms_rowid.rowid_relative_fno(rowid)) as blocks
          from NOLOGGING_TEST
      ) b;
      
|BLOCKS|BLOCKS|GAP|
|------|------|---|
|11,264|10,876|388|
```

