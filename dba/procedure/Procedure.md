[toc]

# Procedure

> not support broadcast operation

절차적 프로그래밍을 지원하는 언어
블럭 구조를 가지며 블럭은 선언부(declare)/실행부(begin)/예외처리부(exception) 구성
블럭은 익명블럭(이름X)과 저장블럭(이름O)으로 구분

pl/sql 블럭의 결과는 화면에 출력되지 않음.
출력방법

1. DBMS_OUTPUT.PUT_LINE 함수를 사용하거나
2. set serveroutput on으로 설정 (sql prompt)

## structure

### 1. declare

- 변수 정의
- in/out 형태 전달
- 데이터 타입 전달
- 생략 가능

### 2. begin

- 정상 동작을 발생시키는 로직
- 제어문, 반복문 등을 정의

### 3. exception

- 에러를 발생시키는 로직 구현
- 생략 가능

## definition

```sql
create or replace procedure insert_job_test1
is
	begin
		insert into tab_job_test1
		values(seq_job_test1.nextval, dbms_random.string('A', 5));
		commit;
	end;
```

