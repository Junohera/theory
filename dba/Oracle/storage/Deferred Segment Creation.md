# Deferred Segment Creation

데이터가 아직 없으므로 segment를 할당하지 않는 현상

## practice

> 빈 TABLE과 INDEX가 생기는 상황을 만들고
> segment를 조회하여 실제로 segment가 할당되었는지 확인하는 실습

```sql
1. 테이블과 인덱스 생성 후, 아무 데이터도 입력하지 않기
create table scott.deferred_segment_creation(no number, name varchar2(10));
create index scott.idx_deferred_segment_creation on scott.deferred_segment_creation(no);

2. 테이블의 세그먼트 확인
select owner, table_name, status, pct_free, pct_used from dba_tables where table_name = 'DEFERRED_SEGMENT_CREATION';
select * from dba_segments where segment_name = 'DEFERRED_SEGMENT_CREATION';

3. 인덱스의 세그먼트 확인
select owner, index_name, status from dba_indexes where index_name = 'IDX_DEFERRED_SEGMENT_CREATION';
select * from dba_segments where segment_name = 'IDX_DEFERRED_SEGMENT_CREATION';
```

