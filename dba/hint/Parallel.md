# Parallel

```sql
-- 현 세션 PARALLEL 활성화
alter session enable parallel ddl|dml|query;

-- PARALLEL 힌트
/*+ parallel(TABLE_NAME|ALIAS CORE) */
```

