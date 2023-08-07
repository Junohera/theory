[toc]

# Procedure Practice

## 1. scott.emp 테이블에서 사원번호가 7369인 사원 이름, 부서번호, 직업 출력

출력형태 : SMITH-20-CLERK

```sql
select ename||'-'||deptno||'-'||job
  from scott.emp
 where empno = 7369;
```

when orange

```sql
-- ref: desc scott.emp;
declare
    vename  varchar2(10);
    vdeptno number(2);
    vjob    varchar2(9);
begin
  select ename, deptno, job into vename, vdeptno, vjob
    from scott.emp
   where empno = 7369;
   
 DBMS_OUTPUT.PUT_LINE(vename||'-'||vdeptno||'-'||vjob);
end;
/
```

<img src="C:\Users\ITWILL\AppData\Roaming\Typora\typora-user-images\image-20230804154826196.png" alt="image-20230804154826196" style="zoom: 50%;" />

when prompt

```sql
SQL> set serveroutput on
declare
    vename  varchar2(10);
    vdeptno number(2);
    vjob    varchar2(9);
begin
  select ename, deptno, job into vename, vdeptno, vjob
    from scott.emp
   where empno = 7369;

 DBMS_OUTPUT.PUT_LINE(vename||'-'||vdeptno||'-'||vjob);
end;
 11   12  /
SMITH-20-CLERK

PL/SQL procedure successfully completed.
```

<img src="C:\Users\ITWILL\AppData\Roaming\Typora\typora-user-images\image-20230804154952820.png" alt="image-20230804154952820" style="zoom: 67%;" />

## 2. scott.emp 테이블에서 사원번호가 7369인 사원의 급여를 allen 급여의 10% 증가값으로 업데이트하라

```sql
declare
  vsal number;
begin
  select sal into vsal
    from scott.emp
   where ename = 'ALLEN';
   
  update emp
     set sal = vsal * 1.1
   where empno = 7369;
end;
/

select sal from emp where empno = 7369;
rollback
select sal from emp where empno = 7369;
```

## 3. 사용자에게 학번을 입력받아 사용자 이름과 시험성적을 아래와 같은 형식으로 출력(참조변수 활용)

> 이름: 서재수, 점수: 95

```shell
SQL> conn scott/oracle
SQL> edit
```

```sql
SQL> edit s2.sql

set serveroutput on
set verify off
set feedback off
accept vstudno prompt '학번을 입력하세요'

declare
	vname  student.name%type;
	vjumsu exam_01.total%type;
begin
  select s.name, e.total into vname, vjumsu
    from student s, exam_01 e
   where s.studno = e.studno
     and s.studno = &vstudno;
   
  dbms_output.put_line('이름: '||vname||', 점수: '||vjumsu);
end;
/
```

## 4. 사용자로부터 번호(no), 이름(name), 주소(addr)값을 입력 받은 후, pl_test1테이블에 값을 입력하는 plsql 구문 작성

```sql
create table pl_test1
(no 		number,
 name		varchar2(10),
 addr  	varchar2(20));
```

### declare - X

```sql
begin
  insert into pl_test1 values(&vno, '&vname', '&vaddr');
  commit;
end;
/
```

### declare - O

```sql
declare
  vno 	number := &ino;
  vname varchar2(10) := '&iname';
  vaddr varchar2(20) := '&iaddr';
begin
  insert into pl_test1 values(vno, vname, vaddr);
  commit;
end;
/
```

## 5. 사용자로부터 두 수를 전달받아 두 수의 합을 아래와 같은 형식으로 출력

> 첫번째 수: 10, 두번째 수: 20, 합: 30

```sql
SQL> edit

### predefine
declare
  n1	 	number := &ia;
  n2 		number := &ib;
  vsum 	number;
begin
  vsum := n1 + n2;
	dbms_output.put_line('첫번째 수: '||n1||', 두번째 수: '||n2||', 합: '||vsum);
end;
/
### immediate calc
declare
  n1	 	number := &ia;
  n2 		number := &ib;
begin
	dbms_output.put_line('첫번째 수: '||n1||', 두번째 수: '||n2||', 합: '||to_char(n1+n2));
end;
/

SQL> /
ia의 값을 입력하십시오: 1
ib의 값을 입력하십시오: 2
첫번째 수: 1, 두번째 수: 2, 합: 3

PL/SQL 처리가 정상적으로 완료되었습니다.

```

## 6. 사원번호를 입력받고 해당 직원의 부서이름을 출력(if 활용)

> 단, 10번이면 인사부
>
> 20번이면 총무부
>
> 30번이면 재무부

```sql
declare
  vempno 		number := &iempno;
  vdeptno		scott.emp.deptno%type;
  vdname		scott.department.dname%type;
begin
	select deptno into vdeptno
	  from scott.emp
	 where empno = vempno;
 	dbms_output.put_line('vdeptno: '||vdeptno);
 	
 	if (vdeptno = 10) then
 	  vdname := '인사부';
 	end if;
 	
 	if (vdeptno = 10) then vdname := '인사부'; end if;
 	if (vdeptno = 20) then vdname := '총무부'; end if;
 	if (vdeptno = 30) then vdname := '재무부'; end if;
 	
 	dbms_output.put_line('10번이면 인사부'||CHR(10)||'20번이면 총무부'||CHR(10)||'30번이면 재무부');
 	dbms_output.put_line('소속부서: '||vdname||'('||vdeptno||')');
end;
/
```

