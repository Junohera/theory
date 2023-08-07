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

## 6. 사번을 입력받고 해당 직원의 부서이름을 출력(if 활용)

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

## 7. 사번을 입력받고 해당 직원의 급여를 아래와 같이 출력

`사번: 7369, 급여등급: B`

> 단, 급여등급은 
> [~, 2000)            C
> [2000, 3000)   B
> [3000, ~)            A

```sql
set serveroutput on
set verify off
set feedback off
accept iempno prompt '사번을 입력하세요: '

declare
  vempno    scott.emp.empno%type := &iempno;
  vsal 			scott.emp.sal%type;
  salgrade	char(1) := 'C';
begin
  select sal into vsal
    from scott.emp
   where 1=1
     and empno = vempno;
  
  if (3000 <= vsal) then
    salgrade := 'A';
  elsif (2000 <= vsal) then
    salgrade := 'B';  
  end if;
  
  dbms_output.put_line('사번: '||vempno||', 급여등급: '||salgrade);
end;
/
```

```sql
iempno의 값을 입력하십시오: 7369
7369
800
사번: 7369, 급여등급: C

PL/SQL 처리가 정상적으로 완료되었습니다.
```

## 8. 학번을 입력받고, 해당 학생의 비만여부 출력

학번: 9411, 비만여부: 표준

> 단, 비만여부는 아래와 같이 계산
>
> 표준체중 = (키 - 100) * 0.9
>
> 체중 > 표준체중 = 과체중
> 체중 < 표준체중 = 저체중
>
> 체중 = 표준체중 = 표준

```sql
set serveroutput on
set verify off
set feedback off

accept istudno prompt '학번을 입력하세요: '

declare
  vstudno scott.student.studno%type := &istudno;
  weight_grade varchar2(3);

  vheight           scott.student.height%type;
  vweight           scott.student.weight%type;
  std_weight        scott.student.weight%type;
  std_weight_grade  varchar2(6);
begin
  select height, weight into vheight, vweight
    from scott.student
   where studno = vstudno;

  std_weight := (vheight - 100) * 0.9;
  std_weight_grade := case when std_weight < vweight then '과체중'
                  	  		 when std_weight > vweight then '저체중'
                                           				   else '표준' end;

  dbms_output.put_line('학번: '||vstudno||', 비만여부: '||std_weight_grade);
end;
/
```

```sql
SQL> edit s8
SQL> @s8
학번을 입력하세요: 9411
학번: 9411, 비만여부: 표준
```

## 9. 1~5 출력

```sql
declare
  no number := 1;
begin
 loop
 	dbms_output.put_line(no);
 	no := no + 1;
 	exit when no >= 6;
 end loop;
end;
/
```

## 10. 구구단 basic loop

```sql
set serveroutput on
set verify off
set feedback off
accept idan prompt '단을 입력하세요: '

declare
  no    number := 1;
  dan   number := &idan;
begin
  loop
    dbms_output.put_line(to_char(dan)||' x '||to_char(no)||' = '||to_char(no * dan, 99999999));
    no := no + 1;
    exit when no >= 10;
  end loop;
end;
/
```

```shell
SQL> edit 10
SQL> @10
```

## 11. 구구단 for

```sql
set serveroutput on
set verify off
set feedback off
accept idan prompt '단을 입력하세요: '

declare
  dan   number := &idan;
begin
  for i in 1..9 loop
    dbms_output.put_line(to_char(dan)||' x '||to_char(i)||' = '||to_char(i * dan, 99999999));
  end loop;
end;
/
```

## 12. 구구단 while

```sql
set serveroutput on
set verify off
set feedback off
accept idan prompt '단을 입력하세요: '

declare
  no    number := 1;
  dan   number := &idan;
begin
  while no < 10 loop
    dbms_output.put_line(to_char(dan)||' x '||to_char(no)||' = '||to_char(no * dan, 99999999));
    no := no + 1;
  end loop;
end;
/
```

