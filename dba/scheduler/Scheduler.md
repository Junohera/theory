[toc]

# Scheduler

## DBMS_JOB

### properties

| 속성      | 설명                        |
| --------- | --------------------------- |
| submit    | 새로운 작업등록             |
| remove    | 삭제                        |
| change    | 변경                        |
| next_date | job에 등록된 작동 시간 변경 |
| interval  | 주기                        |
| what      | 수행할 procedure            |
| run       | 수동으로 등록된 job을 동작  |

### practice

#### 1. 시퀀스를 활용해 특정테이블에 자동데이터 입력

**sequence & table 생성**

```sql
drop sequence seq_job_test1;
create sequence seq_job_test1;
-- same: create sequence seq_job_test1 increment by 1 start with 1;

create table tab_job_test1 (
no			number,
name 		varchar2(10),
created date);
```

**procedure 생성**

```sql
create procedure insert_job_test1
is
	begin
		insert into tab_job_test1
		values(seq_job_test1.nextval, dbms_random.string('A', 5), systimestamp);
		commit;
	end;
/

grant execute on insert_job_test1 to system;
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

## DBMS_SCHEDULER

### practice

#### 2. 시퀀스를 사용한 자동 데이터 입력

```sql
create sequence seq_job_test3;
create table tab_job_test3(
no number,
name varchar2(10),
todate date)
tablespace users;

create or replace procedure insert_job_test3
is
	begin
		insert into tab_job_test3
		values(seq_job_test3.nextval, dbms_random.string('A', 5), systimestamp);
		commit;
	end;
/


vi job.sql
** repeat_interval: monthly, secondly, ...

begin
	dbms_scheduler.create_job(
    job_name=>'job_insert_job_test3',
    job_type=>'plsql_block',
    job_action=>'begin insert_job_test3; end;',
    start_date=>systimestamp,
    repeat_interval=>'freq=secondly; interval=5');
end;
/

exec dbms_scheduler.enable('job_insert_job_test3');
exec dbms_scheduler.disable('job_insert_job_test3');

select *
  from dba_scheduler_jobs
 where job_name like '%TEST%';
 
begin
	dbms_scheduler.drop_job('job_insert_job_test3');
end;
/
```







