[toc]

# Date

> 날짜는 DBMS마다 포맷이 지정되어 있으며
> 명령어 편집 툴도 출력을 위한 포맷이 지정되어 있으니 주의를 해야하고
> 따라서 substr로 날자 추출할 경우에는 DBMS 포맷대로 추출해야 정확한 추출이 가능하다.

## date format handling

**in query**
DBMS의 날짜 포맷을 확인하여 쿼리 작성

**Temporal**
현 세션에서 사용자가 원하는 날짜 포맷으로 변경할 경우, 해당 포맷에 맞게 추출 가능

**Permanent**
DBMS 전체의 날짜 포맷을 변경
(👻최초의 DBMS를 세팅할 때만 사용)

```sql
-- in query
select sysdate,
       substr(sysdate, 1, 4)
  from dual; 
select sysdate,
       '20'||substr(sysdate, 1, 2) as year,
       substr(sysdate, 4, 2) as month,
       substr(sysdate, 7, 2) as day
  from dual;
  
-- Temporal
alter session set nls_date_format = 'YYYY/MM/DD';
```

## sysdate

현재날짜 반환

## date operation

1. date + n: n일 이후 날짜 리턴
2. date - n: n일 이전 날짜 리턴
3. date - date: 두 날짜사이의 일(days) 리턴

```sql
select sysdate,           -- 지금
       sysdate + 100,     -- 100일 뒤
       sysdate - 100,     -- 100일 전
       sysdate-sysdate    -- 두 날짜 사이 기간 일수
  from dual;
```

## months_between

두 날짜 사이의 월수 리턴

```sql
select ename,
       sysdate,
       hiredate,
       trunc(months_between(sysdate, hiredate) / 12) as "윤달 대응 근속연수"
  from emp
 order by hiredate desc;
```

## add_months

월단위 연산 수행

```sql
select sysdate,
       sysdate + 100 as "100 days later",
       sysdate - 100 as "100 days ago",
       add_months(sysdate, 3) as "3 months later",
       add_months(sysdate, -3) as "3 months ago",
       add_months(sysdate, 12*3) as "3 years later",
       add_months(sysdate, -12*3) as "3 years ago"
  from dual;
```

| SYSDATE                 | 100 days later          | 100 days ago            | 3 months later          | 3 months ago            | 3 years later           | 3 years ago             |
| ----------------------- | ----------------------- | ----------------------- | ----------------------- | ----------------------- | ----------------------- | ----------------------- |
| 2023-08-29 19:35:03.000 | 2023-12-07 19:35:03.000 | 2023-05-21 19:35:03.000 | 2023-11-29 19:35:03.000 | 2023-05-29 19:35:03.000 | 2026-08-29 19:35:03.000 | 2020-08-29 19:35:03.000 |

## next_day

특정 요일에 해당하는 바로 다음 날짜 리턴
날짜의 언어 설정에 따라 달라질 수 있음.
`(select *  from v$nls_parameters where parameter = 'NLS_DATE_LANGUAGE';)`
`alter session set nls_date_language = 'koean';`

```sql
select 1, '일', next_day(sysdate, '일'), next_day(sysdate, 1) from dual union all 
select 2, '월', next_day(sysdate, '월'), next_day(sysdate, 2) from dual union all
select 3, '화', next_day(sysdate, '화'), next_day(sysdate, 3) from dual union all
select 4, '수', next_day(sysdate, '수'), next_day(sysdate, 4) from dual union all
select 5, '목', next_day(sysdate, '목'), next_day(sysdate, 5) from dual union all
select 6, '금', next_day(sysdate, '금'), next_day(sysdate, 6) from dual union all
select 7, '토', next_day(sysdate, '토'), next_day(sysdate, 7) from dual;
```

| num  | char | WITH_CHAR               | WITH_NUM                |
| ---- | ---- | ----------------------- | ----------------------- |
| 1    | 일   | 2023-09-03 19:55:04.000 | 2023-09-03 19:55:04.000 |
| 2    | 월   | 2023-09-04 19:55:04.000 | 2023-09-04 19:55:04.000 |
| 3    | 화   | 2023-09-05 19:55:04.000 | 2023-09-05 19:55:04.000 |
| 4    | 수   | 2023-08-30 19:55:04.000 | 2023-08-30 19:55:04.000 |
| 5    | 목   | 2023-08-31 19:55:04.000 | 2023-08-31 19:55:04.000 |
| 6    | 금   | 2023-09-01 19:55:04.000 | 2023-09-01 19:55:04.000 |
| 7    | 토   | 2023-09-02 19:55:04.000 | 2023-09-02 19:55:04.000 |

## last_day

날짜가 포함된 월의 마지막 날짜 리턴

1. 특정 날짜의 마지막날짜는 last_day로 리턴가능함
2. 특정 날짜의 첫번째날짜가 있을법하지만, 존재하지않으므로, trunc(날짜, 'month')로 가능

```sql
select sysdate as "Now",
       trunc(sysdate, 'month') as "First day of this month",
       trunc(last_day(sysdate)) as "Last day of this month"
  from dual;
```

| Now                     | First day of this month | Last day of this month  |
| ----------------------- | ----------------------- | ----------------------- |
| 2023-08-29 20:03:06.000 | 2023-08-01 00:00:00.000 | 2023-08-31 00:00:00.000 |

## extract

날짜 추출

1. 날짜 포맷의 영향을 받지않고, 날짜의 값들을 얻어올 수 있음
2. 리턴타입이 숫자

```sql
select sysdate as "Now",
       extract(year from sysdate) as "Year",
       extract(month from sysdate) as "Month",
       extract(day from sysdate) as "Day",
       extract(hour from systimestamp) + 9 as "Hours",
       extract(minute from systimestamp) as "Minutes",
       extract(second from systimestamp) as "Seconds"
  from dual;
```

| Now                     | Year  | Month | Day  | Hours | Minutes | Seconds  |
| ----------------------- | ----- | ----- | ---- | ----- | ------- | -------- |
| 2023-08-29 20:10:39.000 | 2,023 | 8     | 29   | 20    | 10      | 39.01341 |
