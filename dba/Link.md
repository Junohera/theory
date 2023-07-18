[toc]

# Link

## Manage

### select

```sql
select *
  from dba_db_links;
```

### create

####  1. 이미 tnsnames.ora에 명시된 이름을 사용하는 방법✅

1. db link를 사용할 DB의 tnsnames.ora에 target DB 정보 기재

   ```shell
   cd $ORACLE_HOME/network/admin
   vi tnsnames.ora
   
   LINK_01 =
     (DESCRIPTION =
       (ADDRESS = (PROTOCOL = TCP)(HOST = 172.16.65.132)(PORT = 1521))
       (CONNECT_DATA =
         (SERVER = DEDICATED)
         (SERVICE_NAME = db1)
       )
     )
   
   :wq
   ```

2. 생성

   ```sql
   create public database link LINK_TEST
   connect to system identified by oracle using 'LINK_01';
   
   select *
     from scott.emp@LINK_TEST;
   ```

#### 2. db link 생성시 tns address 전달 방식

1. 생성
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

### create

```sql
create public synonym emp_link2 for scott.emp@link_test2;
create [or replace] public synonym emp_link2 for scott.emp@link_test2;
```

### select

```sql
select * from emp_link2;
```

### drop

```sql
drop public synonym emp_link2;
```

### dba_synonym

```sql
select *
  from dba_synonyms
 where synonym_name like 'EMP_LINK2';
 
|OWNER |SYNONYM_NAME|TABLE_OWNER|TABLE_NAME|DB_LINK   |
|------|------------|-----------|----------|----------|
|PUBLIC|EMP_LINK2   |SCOTT      |EMP       |LINK_TEST2|
```

