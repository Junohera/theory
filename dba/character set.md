[toc]

# character set

## nls 관련 파라미터

### 조회

~~~sql
select * from sys.props$;
~~~

### 수정

```sql
update sys.props$ set value$ = 'KOREAN' where name = 'NLS_LANGUAGE';
update sys.props$ set value$ = 'KOREA' where name = 'NLS_TERRITORY';
update sys.props$ set value$ = 'AL32UTF8' where name = 'NLS_CHARACTERSET';
commit; 
```

## linux environment

```shell
vi ~/.bash_profile

export LANG=ko_KR.UTF-8 
export NLS_LANG=KOREAN_KOREA.AL32UTF8
:wq

. ~/.bash_profile
```

## apply

```sql
sqlplus / as sysdba
SQL> STARTUP MOUNT;

SQL> ALTER SYSTEM ENABLE RESTRICTED SESSION;
SQL> ALTER DATABASE OPEN;
SQL> alter database character set internal_use AL32UTF8;
SQL> SHUTDOWN IMMEDIATE;
SQL> STARTUP MOUNT;
SQL> ALTER SYSTEM DISABLE RESTRICTED SESSION;
SQL> ALTER DATABASE OPEN;
```

---

## trouble shooting

1. 여전히 깨져있다면, 해당 테이블을 재생성

2. undo error발생시 undo autoextend on
   ```sql
   alter database datafile 'undodatafile' autoextend on;
   ```

