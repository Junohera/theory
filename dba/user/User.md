[toc]

# User

## Schema

- 특정 사용자가 생성한 object 의 집합을 의미
- user가 생성될 때 관련 schema가 생성됨.
- user와 schema를 혼용해서 사용하기도 함.

## Schema Object

- Tables
- Indexes
- Views
- Triggers 
- Constraints 
- Database links 
- Synonyms 
- Stored Procedures 
- Sequences

## Manage

### create

```sql
create user tuser identified by oracle
default tablespace users
temporary tablespace temp
quota unlimited on users
quota 100m on users2
profile default
;
```

### grant

```sql
grant create session to tuser;
```

### select

```sql
select username,
			 account_status,						-- 계정 상태
			 lock_date,
			 expiry_date,
			 default_tablespace,
			 temporary_tablespace,
			 profile
  from dba_users
 where 1=1
   and username = 'TUSER'
;
```
