# Row Level Flashback

특정 테이블 단위로 시점복구하는 것이 아닌,
특정 행 단위로 변경된 이력 조회하고, 이를 바탕으로 복구 진행
undo image를 사용한 복구진행 => 오래되거나 대용량 dml발생으로 undo에서 조회할 수 없을 경우 복구 불가



## 추가 전제조건

- undo에서 statement fetch 가능하도록 설정

```sql
alter database add supplemental log data;
```

## 이력조회 테이블

### 1. flashback version query

해당 row 변경 이력

### 2. flashback transaction query

해당 시점 이전 row로 되돌리는 sql 제공

> 예) emp 에서 ename이 smith의 sal의 변경이력
>
> 800 -> 1200 -> 1600 -> 0



## practice

### 1. 테스트 테이블 생성

```sql
create table flashback_test (
  no 			number,
  ename		varchar2(10),
  sal number
);

insert into flashback_test values(1, '홍길동', 800);
insert into flashback_test values(2, '박길동', 1500);

select * from flashback_test;
|NO |ENAME|SAL  |
|---|-----|-----|
|1  |홍길동  |800  |
|2  |박길동  |1,500|
```

### 2. 잘못된 dml 수행 1(update)

```sql
update flashback_test
   set sal = 1200
 where no = 1;
commit;

update flashback_test
   set sal = 1600
 where no = 1;
commit;

update flashback_test
   set sal = 0
 where no = 1;
commit;

select * from flashback_test;
|NO |ENAME|SAL  |
|---|-----|-----|
|1  |홍길동  |0    |
|2  |박길동  |1,500|
```

### 3. flashback version query 조회

```sql
select versions_startscn st_scn
     , versions_endscn endscn
     , versions_xid txid
     , versions_operation opt
     , sal                    -- 복구 하고자 하는 column_name
  from flashback_test versions between scn minvalue and maxvalue
 where no = 1

|ST_SCN   |ENDSCN   |OPT|SAL  |
|---------|---------|---|-----|
|2,904,737|         |U  |0    |
|2,904,735|2,904,737|U  |1,600|
|2,904,733|2,904,735|I  |1,200|
```

### 4. flashback transaction query 조회

> undo를 뒤지기때문에 엄청 느림

```sql
select undo_sql u1
  from flashback_transaction_query
 where table_name = 'FLASHBACK_TEST'
   and commit_scn between ${FROM_SCN} and ${TO_SCN}
 order by start_timestamp desc;
```

#### TODO: 5. 복구
