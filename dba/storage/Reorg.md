[toc]

# Reorg

>  블럭 재구성

- delete를 해도 freeblock을 반환하지 않아 실제건수 대비 디스크영역이 너무 많아져 성능저하
- 실제 사용하는 건수에 맞게 물리적인 공간을 재배치하여 성능 향상 --> 재구성 필요
- reorg 대상: 해당 테이블의 전체 블럭수와 실사용 블록수의 차이를 확인하면 알 수 있음.

## **재구성**

이미 속해있던 동일한 tablespace로 move시키면 실제사용하는 데이터에 맞게 블럭들이 재배치됨

```sql
alter table scott.STG_TEST1 move tablespace USERS2;
```

## **할당된 블록수 조회**

```sql
select sum(BLOCKS) as "할당된 블록수"
  from dba_extents
 where segment_name = 'NOLOGGING_TEST';
```

## **실사용 블록수 조회**

재구성 전/후로 조회해야할 쿼리

```sql
select count(
         distinct dbms_rowid.rowid_block_number(rowid) || 
         dbms_rowid.rowid_relative_fno(rowid)
       ) as "실사용 블록수" 
  from NOLOGGING_TEST;
```

## **할당된 블록수:실사용블록수 조회**

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

