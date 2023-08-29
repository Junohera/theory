[toc]

# General

### nvl

> nvl(target, substitution value)

```sql
select sal,
       comm,
       nvl(comm, 0),
       sal+nvl(comm, 0)
  from emp;
```

### nvl2

> nvl2(target, value when not null, value when null)

```sql
select ename, sal,
       comm,
       nvl(comm, 500),
       nvl(comm, 0) + 500,
       nvl2(comm, comm+500, 500)
  from emp;
```

### decode

> decode(target, condition1, substitution1, condition2, substitution2, ...)
>
> 1. 조건과 치환은 계속 반복하여 나열 가능
> 2. 조건은 항상 일치대상
> 3. 조건이 없는 치환값은 그외 치환값을 의미
> 4. 그외 치환값은 생략가능, 생략시 널리턴
> 5. decode 중첩을 사용해야할 경우, case로 대체하는 것이 성능상 이점✅

```sql
select ename,
       deptno,
       decode(deptno, 10, '총무부',
                      20, '재무부',
                      30, '총괄부', '기타') as deptname
  from emp;
  
select empno,
       ename,
       deptno,
       sal,
       decode(deptno, 10, sal*1.1,
                      20, sal*1.11,
                      30, sal*1.12) as new_sal
  from emp
 order by deptno, sal desc;
```

### case

> sql에서의 조건문(PL/SQL에서는 IF문)
>
> 1. 모든 조건의 형태 전달 가능(대소비교, in, between, like, 논리연산자)
> 2. else를 생략할 경우, 널리턴
> 3. 축약문법이 존재
>    💥 축약문법을 사용할 경우 비교대상과 값의 데이터 타입이 일치하지 않으면 에러발생

```sql
select ename,
       deptno,
       case deptno when 10 then '총무부'
                   when 20 then '재무부'
                   when 30 then '총괄부' else '기타'
        end as deptname
  from emp;
  
select empno,
       ename,
       deptno,
       sal,
       case when deptno = 10 then sal*1.1
            when deptno = 20 then sal*1.11
            when deptno = 30 then sal*1.12
        end as new_sal
  from emp
 order by deptno, sal desc;
```

