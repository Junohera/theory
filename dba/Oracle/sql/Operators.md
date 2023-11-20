[toc]

# Operators

1) 비교연산자 : =, !=, >, <, >=, <=
2) 논리연산자 : and, or, not(우선순위: not > and > or)
3) 기타연산자 : between A and B, in, like

## between A and B

> between A and B : A 이상 B 이하(포함)
> A, B에는 숫자, 문자, 날짜 가능
> A < B(더 큰 값을 뒤쪽에 배치)

```sql
-- and
select *
  from emp
 where sal >= 1000
   and sal <= 3000;
-- between
select *
  from emp
 where sal between 1000 and 3000;
-- not between
select *
  from emp
 where sal not between 1000 and 3000;
```

## in

> or 연산자의 축약형(포함연산자)

```sql
# in
select name, grade, height, weight
  from student
 where name in ('김신영', '오나라', '일지매');
# not in
select name, grade, height, weight
  from student
 where name not in ('김신영', '오나라', '일지매');
```

## like

> 패턴 검색
> `%`: 글자수 상관없이 모든
> `_`: 한 글자의 모든

```sql
where ename like 'S%' -- S로 시작하는
where ename like '%S' -- S로 끝나는
where ename like '%S%' -- S를 포함하는
where ename like 'S_' -- S로 시작하는 두글자
```

