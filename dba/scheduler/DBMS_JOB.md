[toc]

# DBMS_JOB

## properties

| 속성      | 설명                        |
| --------- | --------------------------- |
| submit    | 새로운 작업등록             |
| remove    | 삭제                        |
| change    | 변경                        |
| next_date | job에 등록된 작동 시간 변경 |
| interval  | 주기                        |
| what      | 수행할 procedure            |
| run       | 수동으로 등록된 job을 동작  |

## practice

### 1. 시퀀스를 활용해 특정테이블에 자동데이터 입력

**sequence & table 생성**

```sql
drop sequence seq_job_test1;
create sequence seq_job_test1;
-- same: create sequence seq_job_test1 increment by 1 start with 1;

create table scott.tab_job_test1 (
no		number,
name 	varchar2(10));
```

**procedure 생성**

```sql
create or replace procedure insert_job_test1
is
	begin
		insert into tab_job_test1
		values(seq_job_test1.nextval, dbms_random.string('A', 5));
		commit;
	end;
```

**job 생성**

```sql
vi job.sql

begin
	dbms_job.submit(
    :jno,										-- job 번호
    'insert_job_test1;',		-- 프로시져이름
    sysdate,								-- 시작지점
    'sysdate + 1/24/60',		-- 주기(1분에 한번 수행)
    false);
end;
/
```

**job 실행**

```sql
-- 변수 선언
SQL> variable jno number;

SQL> @job.sql

-- 변수 출력(자동으로 부여되는 job 번호 확인)
SQL> print jno;	

-- job 등록
SQL> commit;		
```

**job 실행 확인**

```sql
select *
  from dba_jobs
 where 1=1
   and what = 'insert_job_test1;'
;
```

**테이블 확인**

```sql
select *
  from tab_job_test1;
```

**job 삭제**

```sql
exec dbms_job.remove(${JOB_NUMBER}); 
exec dbms_job.remove(1);
commit;
```

**job 수정**

```sql
exec dbms_job.change(
  1,
  'insert_job_test1;',
  sysdate,
  'sysdate + 30/24/60');
```





