# SQLPLUS

## option

```shell
sqlplus -s /nolog << _EOF_ > /dev/null
conn / as sysdba
set head off
set lines 10000
set pages 10000
set feedback off
set echo off
set term off

spool ./abc.sh

select sysdate
  from dual;
/

spool off
_EOF_
```

## spool

> tee와 동일함. 결과를 shell file로 남김

```shell
spool ${SHELL_FILE}

${QUERY}

/

spool off
```

## conn

커넥션 전환

```sql
SQL> conn system/oracle
```
