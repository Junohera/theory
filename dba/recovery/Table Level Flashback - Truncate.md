[toc]

# Table Level Flashback - Truncate

### 1. 테이블 확인

```sql
select * from flashback_test;
```

### 2. select systimestamp from dual;

```sql
select systimestamp from dual;
```

### 3. truncate table flashback_test;

```sql
truncate table flashback_test;
select * from flashback_test;
```

### 4.복구시도