[toc]

# Reorder columns

## practice

### 1. 중간에 컬럼위치되도록 컬럼을 추가하는 경우

> example
>
> `EMP` 테이블의 세번째 컬럼에 `BIRTHDAY` 컬럼 추가
>
> EMPNO, ENAME, BIRTHDAY, JOB, MGR, ..., DEPTNO

#### is not exists default) 컬럼 추가시 데이터가 null로 들어가기 때문에 빠름

```sql
alter table scott.emp add birthday date;
desc scott.emp;

alter table scott.emp drop column birthday;
```

#### is default) 컬럼 추가시 데이터가 default값으로 update되기 때문에 매우느림

```sql
💥 WORST 💥
alter table scott.emp add birthday2 date default sysdate;💥
desc scott.emp;

✅ BEST ✅
> update는 parallel힌트를 사용할 수 있으므로 default값 없이 컬럼을 추가하고 수정한 후 default값 부여
-- 1. 기본값 없이 컬럼추가
alter table scott.emp add birthday2 date;
-- 2. parallel 힌트사용하면서 기본값 적용
update /*+ parallel(e 8) */ scott.emp
   set birthday2 = sysdate;
commit;
-- 3. lazy 기본값 적용
alter table scott.emp modify birthday2 default sysdate not null;
-- 4. 기본값 확인
select table_name, column_name, data_type, data_default
  from dba_tab_columns
 where table_name = 'EMP';
```

#### 수행

```sql
alter session enable parallel dcl;

CREATE TABLE SCOTT.EMP_BACK
(
    EMPNO       NUMBER(4) NOT NULL,
    ENAME       VARCHAR2(10),
    BIRTHDAY    DATE,✅
    JOB         VARCHAR2(9),
    MGR         NUMBER(4),
    HIREDATE    DATE,
    SAL         NUMBER(7,2),
    COMM        NUMBER(7,2),
    DEPTNO      NUMBER(2)
)
TABLESPACE USERS
PARALLEL 8;

-- TABLE의 prallel 현황 조회
-- ✅테이블 생성시 parallel 지정시 모든 DML, DQL에 대해 자동으로 PARALLEL로 접근되므로, 작업 이후 원복 필요
select table_name, degree
  from dba_tables
 where table_name = 'EMP_BACK';
|TABLE_NAME|DEGREE    |
|----------|----------|
|EMP_BACK  |         8|

-- CASE1) DEFAULT❌
insert into scott.emp_back(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO)
select *
  from scott.emp;
rollback;

-- CASE2) DEFAULT⭕
insert into scott.emp_back
select EMPNO, ENAME, sysdate as birthday, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO 
  from scott.emp;
commit;

-- alter NO PARALLEL
alter table scott.emp_back noparallel;

-- check no parallel
select table_name, degree
  from dba_tables
 where table_name = 'EMP_BACK';
|TABLE_NAME|DEGREE    |
|----------|----------|
|EMP_BACK  |         1|

-- 원본 테이블 삭제
drop table scott.emp;

-- 백업 테이블 rename
rename emp_back to emp; -- as a owner

-- 이관 후속작업
```

