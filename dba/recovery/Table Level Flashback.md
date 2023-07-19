[toc]

# Table Level Flashback

> dml로 인해 데이터 손실이 발생한 경우
> 특정 시점의 테이블  단위로 이전 이미지를 공급, 이를 통해 복구 가능

**전제조건** 

1. enabled flashback
   ```sql
   select flashback_on from v$database;
   ```

   

**flashback on/off 여부**

```sql
SQL> select flashback_on from v$database;

FLASHBACK_ON
------------------
NO
```

## 종류

### 1. flashback query✅

> **query를 사용한 복구**
>
> 쿼리를 작성해야하는 번거로움이 있지만,
> 추가적인 조치를 취하기가 쉽고, 응용하기가 좋음.
> (또다시 잘못된 dml을 수행하거나 CTAS등을 활용가능)

### 2. ~~flashback table~~

> **바로 특정 시점의 테이블 데이터로 변경**
>
> 쿼리를 작성할 필요없어 가장 편함.
> 응용조치를 할 수 없음.
> 블록의 이동에 영향을 주기 때문에 1번(`flashback query`)을 권장하고, 사용하더라도 rowmovement를 다시 disable 시켜주는게 좋다.
>
> ### 추가 전제조건
>
> - rowmovement enable
>   ```sql
>   select row_movement from dba_tables where table_name = 'FRUITS';
>   alter table fruits enable row movement;
>   select row_movement from dba_tables where table_name = 'FRUITS';   -- ENABLED
>   ```

## 관리

### flashback - query

#### 현재 시점 확인

```sql
select sysdate, systimestamp from dual;
|SYSDATE                |SYSTIMESTAMP                 |
|-----------------------|-----------------------------|
|2023-07-19 11:22:51.000|2023-07-19 11:22:51.614 +0900|

select to_timestamp('2023-07-19 11:24:35', 'YYYY-mm-dd HH24:MI:SS') from dual;
|TO_TIMESTAMP('2023-07-1911:24:35','YYYY-MM-DDHH24:MI:SS')|
|---------------------------------------------------------|
|2023-07-19 11:24:35.000                                  |
```

#### 특정시점의 데이터 조회

```sql
select /*+ parallel(f 8) */*
  from fruits f
    as of timestamp to_timestamp('2023-07-19 11:22:51', 'YYYY-mm-dd HH24:MI:SS');
|NO |NAME  |PRICE|
|---|------|-----|
|1  |apple |2,500|
|2  |grape |3,000|
|3  |orange|1,000|
```

#### enable parallel hint

```sql
alter session enable parallel dml;
```

#### 특정 시점의 데이터 조회

```sql
select /*+ parallel(f2 8) */
  from fruits f2
    as of timestamp to_timestamp('2023/07/19 11:24:29', 'YYYY/MM/DD HH24:MI:SS');
```

### flashback - table

#### on/off row movement 

```sql
select row_movement from dba_tables where table_name = 'FRUITS';
alter table fruits disable row movement;
alter table fruits enable row movement;
```

#### flashback table로 복구

```sql
-- absolute timestamp
flashback table fruits 
          to timestamp(to_timestamp('2023/07/19 11:24:29', 'YYYY/MM/DD HH24:MI:SS'));

-- relative timestamp
flashback table fruits 
          to timestamp(systimestamp - interval '1' hour);
```

