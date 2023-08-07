[toc]

# Variable

## definition

VARIABLE_NAME [constant] datatype [not null] [ := VALUE|DEFAULT VALUE] 

- constant: immutable read only(final)
- := value | default value : 값을 직접 상수로 전달하거나 default 값 선언

```sql
# ❌
a1 = 1
# ✅
a1 := 1
```

### scala

변수를 직접 정의(데이터 타입 선언)

```sql
# 변수명 [constant] datatype [not null] [ := value | default value]
vno number
vno number := 1
```

### reference

다른 객체의 데이터타입 참조하는 선언 방식(특정 테이블의 컬럼과 같은 데이터타입을 참조하는 변수 선언 방식)

```sql
변수명 테이블명.컬럼명%type
vno emp.empno%type
```

## external variable

```sql
SQL> conn scott/oracle
SQL> set serveroutput on

declare
  vename  varchar2(10);
  vdeptno number(2);
  vjob    varchar2(10);
begin
  select ename, deptno, job into vename, vdeptno, vjob
    from scott.emp
   where empno = &vempno;
   
  DBMS_OUTPUT.PUT_LINE(vename||'-'||vdeptno||'-'||vjob);
end;
/

SQL> edit

select ename, sal from scott.emp
:wq
/

SQL> ed s1.sql

set serveroutput on
set verify off
set feedback off
accept vempno prompt '사원번호를 입력하세요(prompt에서 전달받을 때 출력할 메시지): '

declare
  vename  varchar2(10);
  vdeptno number(2);
  vjob    varchar2(10);
begin
  select ename, deptno, job into vename, vdeptno, vjob
    from scott.emp
   where empno = &vempno;
   
  DBMS_OUTPUT.PUT_LINE(vename||'-'||vdeptno||'-'||vjob);
end;
/

SQL> edit
||
SQL> ed

select ename, sal from scott.emp;
:wq
/

SQL> @s1.sql
```

