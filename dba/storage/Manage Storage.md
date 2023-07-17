[toc]

# Manage Storage

## PCTFREE

- `default 10%`
- block내 update를 위해 비워두는 공간
- 작으면 update시 잦은 row migration[^row migration] 발생
- 크면 (100-pctfree)%내에 insert 가능한 공간으로 할당되므로 적은 양의 데이터가 저장

## PCTUSED

- delete 수행시 즉각 free공간으로 할당하지 않음.
- pctused 공간 이상 빈공간이 발생할 경우, 이 block을 free block 반환

---

## 관리

### 할당량 수정

```sql
alter user scott quota unlimited on users2;
```

### 생성

```sql
create table scott.stg_test1
(no		number,
 name	varchar2(20),
 addr  varchar2(20))
tablespace users2;
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

```sql
analyze table scott.stg_test1 compute statistics;
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

-- 통계정보 갱신
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

-- 통계정보 갱신
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
```





---

# foot note

[^row migration]: TODO