하기 쿼리의 컨셉은 온라인 중인 데이터베이스에
부하를 주지않는 통계정보를 기반으로
조사하는 방법이다. (= 다소 복잡한 쿼리가 될 수 밖에 없음)
막말로 select count(*) from target_table등을 날리지 않기 위함.

### bloating table 조사

> 실무에서 사용할 경우 쿼리 수정 필요(해봐야 암)

```sql
SELECT a.oid::regclass,
   age(a.relfrozenxid),
   a.relpages * 8192 AS relsize,
   ceil((b.n_live_tup * c.stawidth) * 1.0 / 8192) * 8192 AS actualsize,
   int4((a.relpages * 8192) / (ceil((b.n_live_tup * c.stawidth) * 1.0 / 8192) * 8192)) AS ratio_bloat,
   last_vacuum,
   last_autovacuum
FROM pg_class a
LEFT JOIN pg_stat_all_tables b ON a.oid = b.relid
LEFT JOIN
 (SELECT starelid,
     sum(stawidth) AS stawidth
 FROM pg_statistic
 GROUP BY starelid) c ON a.oid = c.starelid
WHERE relkind IN ('r', 'm')
 AND a.relname <> 'pg_statistic'
 AND relpages > 0
 AND int4((a.relpages * 8192) / (ceil((b.n_live_tup * c.stawidth) * 1.0 / 8192) * 8192)) > 1
ORDER BY 2;
```

### bloating index 조사

```sql
SELECT a.oid::regclass,
      a.relpages * 8192 AS relsize,
      ceil(b.keywidth * 1.0 * c.n_live_tup / 7373) * 8192 + 8192 AS actualsize,
      round((a.relpages * 8192 * 1.0) / (ceil(b.keywidth * 1.0 * c.n_live_tup / 7373) * 8192 + 8192), 0) AS bloatratio
FROM pg_class a,
 (SELECT a.indexrelid,
         a.indrelid,
         sum(b.stawidth + 1) + 9 AS keywidth
  FROM pg_index a,
       pg_statistic b
  WHERE a.indrelid = b.starelid
    AND arraycontains(string_to_array(a.indkey::text, ' '), array[b.staattnum::text])
  GROUP BY a.indexrelid,
           a.indrelid) b,
    pg_stat_all_tables c
WHERE a.oid = b.indexrelid
 AND b.indrelid = c.relid
 AND round((a.relpages * 8192 * 1.0) / (ceil(b.keywidth * 1.0 * c.n_live_tup / 7373) * 8192 + 8192), 0) > 2;
```

