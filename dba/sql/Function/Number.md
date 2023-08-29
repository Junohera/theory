# Number

- round: 반올림
- trunc: 버림(0으로 향함)
- mod: 나머지
- ceil: 올림
- floor: 버림(무조건 소수점 아래를 향함)
- abs: 절대값
-  sign: 신호

```sql
select n,
       round(n),
       trunc(n),
       trunc(n/30) as 몫,
       mod(n, 30) as 나머지,
       ceil(n),
       floor(n),
       abs(n),
       sign(n)
  from (select 100.45 as n
          from dual)
;
```

| N      | ROUND(N) | TRUNC(N) | 몫   | 나머지 | CEIL(N) | FLOOR(N) | ABS(N) | SIGN(N) |
| ------ | -------- | -------- | ---- | ------ | ------- | -------- | ------ | ------- |
| 100.45 | 100      | 100      | 3    | 10.45  | 101     | 100      | 100.45 | 1       |