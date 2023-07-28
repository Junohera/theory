# Status Check



## 상태체크

### listener

```shell
ps -ef | grep lsnr | grep -v grep
```

### pmon

```shell
ps -ef | grep pmon | grep -v grep
```

### connect

```shell
sqlplus system/oracle@db1 -- listener 있어야만 실행됨
[oracle@oel7 admin]$ sqlplus system/oracle@db1

SQL*Plus: Release 12.2.0.1.0 Production on Fri Jul 28 14:28:23 2023

Copyright (c) 1982, 2016, Oracle.  All rights reserved.

ERROR:
ORA-12541: TNS:no listener
```

```shell
sqlplus system/oracle  as sysdba -- listener 없어도 실행됨.
```

### query



## SQLPLUS

### option

```shell
sqlplus -s /nolog << _EOF_ > /dev/null
conn / as sysdba
set head off
set lines 10000
set pages 10000
set feedback off
set echo off
set term off

spool ${PATH}/abc.sh

${QUERY}
/

spool off

_EOF_
```



### spool

> tee와 동일함. 결과를 shell file로 남김

```shell
spool ${SHELL_FILE}

${QUERY}

/

spool off
```

### tar

```shell
-- UNZIP
tar -xvf ${TAR}
-- LIST
tar -tvf ${TAR}
```

