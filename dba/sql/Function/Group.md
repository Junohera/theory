[toc]

# Group

> 출력이 하나

- count
- sum
- avg
- min
- max
- variance: 분산
- stddev: 표준편차

```sql
select count(n), sum(n), avg(n), min(n), max(n), variance(n), stddev(n)
  from (select 0 + level as n
          from dual
       connect by level <= 10);
```

| COUNT(N) | SUM(N) | AVG(N) | MIN(N) | MAX(N) | VARIANCE(N)  | STDDEV(N)    |
| -------- | ------ | ------ | ------ | ------ | ------------ | ------------ |
| 10       | 55     | 5.5    | 1      | 10     | 9.1666666667 | 3.0276503541 |

## group by

그룹함수의 계산 영역을 전달하는 절
내부적으로 항상 정렬을 수행하게 되어있지만, 출력되는 결과에서는 정렬보장 없음

> ✅ Separate -> Apply -> Combine

## having

groupby의 수행 결과에 필터링을 원할 경우 사용
groupby와 having의 순서는 변경해도 실행상에 문제가 되지 않지만 이는 권하지않는다.

> 🎨 where vs having
>
> 이 둘의 성능 차이는 데이터베이스의 크기, 인덱스의 존재 여부, 데이터의 분산 정도, 쿼리의 복잡성 등 여러 요소에 따라 다르겠지만,
> 일반적으로 `WHERE` 절을 사용하여 가능한 한 데이터를 빨리 필터링하고
> 그 이후에 `HAVING` 절을 사용하여 그룹화된 데이터를 필터링하는 것이 성능을 향상시킬 수 있는 방법이고
>
> 또한 적절한 인덱스를 사용하고 쿼리를 최적화하여 성능을 최대화할 수 있습니다.

## distinct

```sql
-- distinct
select distinct n
  from (select trunc(0 + level/2) as n
          from dual
       connect by level <= 10);
-- all(default)
select all n
  from (select trunc(0 + level/2) as n
          from dual
       connect by level <= 10);
```

---

## tip

**emp 테이블을 이용하여 각 부서별 직원수를 출력**

> 다음과 같이 개별로 쿼리를 실행하게 되면
> 결과를 위한 값은 얻어오지만 
> 디스크에 여러번 접근을 하여 합칠 수 있다고 한들 성능적으로 좋지않음.
>
> ```sql
> select count(empno) as "10_직원수" from emp where deptno = 10 group by deptno;
> select count(empno) as "20_직원수" from emp where deptno = 20 group by deptno;
> select count(empno) as "30_직원수" from emp where deptno = 30 group by deptno;
> 
> select 10 as 부서, count(empno) as 직원수 from emp where deptno = 10 group by deptno
>  union all
> select 20, count(empno) from emp where deptno = 20 group by deptno
>  union all
> select 30, count(empno) from emp where deptno = 30 group by deptno;
> ```
>
> | 부서 | 직원수 |
> | ---- | ------ |
> | 10   | 3      |
> | 20   | 5      |
> | 30   | 6      |

```sql
-- count 또는 sum의 NULL을 무시하는 특성을 활용하면 디스크에 접근은 한번하면서 결과를 얻을 수 있음
select 'sum' as func_name,
       sum(decode(deptno, 10, 1)) as "10_직원수",
       sum(decode(deptno, 20, 1)) as "20_직원수",
       sum(decode(deptno, 30, 1)) as "30_직원수"
  from emp
 union all  
select 'count',
       count(decode(deptno, 10, 1)) as "10_직원수",
       count(decode(deptno, 20, 1)) as "20_직원수",
       count(decode(deptno, 30, 1)) as "30_직원수"
  from emp;
```

| FUNC_NAME | 10_직원수 | 20_직원수 | 30_직원수 |
| --------- | --------- | --------- | --------- |
| sum       | 3         | 5         | 6         |
| count     | 3         | 5         | 6         |