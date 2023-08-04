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