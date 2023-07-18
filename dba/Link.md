[toc]

# Link

## Manage

### select

```sql
select *
  from dba_db_links;
```

### create

####  1. reference tnsnames.ora✅

```sql
vi $ORACLE_HOME/network/admin/tnsnames.ora

LINK_01 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 172.16.65.132)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = db1)
    )
  )

:wq

create public database link LINK_TEST
connect to system identified by oracle using 'LINK_01';

select *
  from scott.emp@LINK_TEST;
```

#### 2. ~~literal~~

```sql
create public database link LINK_TEST2
connect to system identified by oracle
using '(DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 172.16.192.129)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = db1)
    )
  )';
  
select *
  from scott.emp@LINK_TEST2;
```

### drop

```sql
drop public database link LINK_TEST;
drop public database link LINK_TEST2;
```

## With Synonym

>  synonym을 DBLink와 엮어 데이터 접근시 복잡도를 단순화

### 1. create

```sql
create public synonym emp_link2 for scott.emp@link_test2;
create [or replace] public synonym emp_link2 for scott.emp@link_test2;
```

### 2. select

```sql
select * from emp_link2;
```

### 3. drop

```sql
drop public synonym emp_link2;
```

### 4. synonyms

```sql
select *
  from dba_synonyms
 where synonym_name like 'EMP_LINK2';
 
|OWNER |SYNONYM_NAME|TABLE_OWNER|TABLE_NAME|DB_LINK   |
|------|------------|-----------|----------|----------|
|PUBLIC|EMP_LINK2   |SCOTT      |EMP       |LINK_TEST2|
```

