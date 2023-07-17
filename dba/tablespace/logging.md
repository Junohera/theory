## logging

### 조회

```sql
select table_name,
       tablespace_name, status, logging
  from dba_tables;
```

### 수정

```sql
alter table nologging_test3 logging;
```

