[toc]

# Transmission Mode

## Conventional Mode

일반 insert처럼 한건씩 처리하는 방식

## Direct Mode

대용량 데이터 적재를 빠르게 처리하기 위한 적재 방식

데이터 버퍼 캐시를 사용하지 않고, 디스크에 직접 기록

redo buffer의 사용을 최소하면서 데이터 적재

대신 복구시 문제가 될 수 있으므로 백업을 수행하는게 사실상 필수

---

## Practice

### 1. 제약 조건 및 인덱스 테스트

> 일부러 제약조건에 위배되는 데이터를 컨벤셔널모드와 다이렉트모드일 때 결과를 비교
>
> `Conventional Mode`
>
> 한건한건 insert하는 행위와 동일하다보니
>
> index와 constraint에 맞지 않으면 데이터 입력이 불가능
>
> `Direct Mode`
>
> 목적상 디스크에 곧바로 쓰기위한 모드이므로
>
> 제약조건에 위배가 될 경우 disabled ${TARGET_CONSTRAINT}
>
> 인덱스에 위배가 될 경우 unusable ${TARGET_INDEX}
>
> 처리되지만 데이터는 조회된다.

```sql
1. 테이블 생성
create table scott.tns_mode_test(no number, name varchar2(10));
alter table scott.tns_mode_test add constraint pk_tns_mode_test_no primary key (no);

2. 데이터 생성
vi tns_mode_test.txt
no,name
1,a
2,b
3,c
4,d
4,e

3. 적재 시도
sqlldr scott/oracle control=${CONTROL_FILE} direct=y|n
```

#### when conventional mode

```shell
sqlldr scott/oracle control=tns_mode_test

Record 5: Rejected - Error on table TNS_MODE_TEST.
ORA-00001: unique constraint (SCOTT.PK_TNS_MODE_TEST_NO) violated


Table TNS_MODE_TEST:
  4 Rows successfully loaded.
  1 Row not loaded due to data errors.
  0 Rows not loaded because all WHEN clauses were failed.
  0 Rows not loaded because all fields were null.
```



#### when direct mode

```shell
sqlldr scott/oracle control=tns_mode_test direct=y

The following index(es) on table TNS_MODE_TEST were processed:
ORA-39828: Constraint PK_TNS_MODE_TEST_NO was disabled because of index SCOTT.PK_TNS_MODE_TEST_NO error.
index SCOTT.PK_TNS_MODE_TEST_NO was made unusable due to:💥
ORA-01452: cannot CREATE UNIQUE INDEX; duplicate keys found

Table TNS_MODE_TEST:
  5 Rows successfully loaded.✅
  0 Rows not loaded due to data errors.
  0 Rows not loaded because all WHEN clauses were failed.
  0 Rows not loaded because all fields were null.
```

#### direct mode 이후의 결과

```sql
select constraint_name, status, validated from dba_constraints where TABLE_NAME = 'TNS_MODE_TEST';
|CONSTRAINT_NAME    |STATUS    |VALIDATED    |
|-------------------|----------|-------------|
|PK_TNS_MODE_TEST_NO|DISABLED💥|NOT VALIDATED|

select index_name, status from dba_indexes where table_name ='TNS_MODE_TEST';
|INDEX_NAME         |STATUS    |
|-------------------|----------|
|PK_TNS_MODE_TEST_NO|UNUSABLE💥|

```

