# NULL

아직 입력되지 않은 값(공백이나 0과는 다름)
NULL을 포함한 산술연산의 결과는 항상 NULL을 리턴

```sql
-- IS NULL
select *
  from emp
 where comm is null;
-- IS NOT NULL
select *
  from emp
 where comm is not null;
```

### 🎨

```sql
-- with Arithmetic Operator
select ename,
			 sal,
       comm,
       sal + comm as 급여1, -- null 출력
       sal + nvl(comm, 0) as 급여2 -- 정상 출력
  from emp;
```

위의 코드를 실행하면 급여1의 경우, null이 출력되어 의도와 다를 수 있음.
위와 같은 현상을 방지하려면 사전에 해당 컬럼의 NULLABLE을 확인하여 쿼리를 작성하도록 하는 것이 좋다.



