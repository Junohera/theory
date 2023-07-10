[toc]

# Oracle Instance Life Cycle

## Startup

`startup [step]`

### 1. nomount

> **Parameter file**

파라미터 파일 내용대로 인스턴스 구성(`only memory`)

이때부터 alertlog에 기록

### 2. mount

> **Control file**

디스크 구성(`from disk`)

control file을 읽고, 문제가 없다면 mount 돌입
(control file은 parameter file에 기입)

```shell
cd ${ORACLE_HOME}/dbs
vi initdb1.ora
...
16 *.control_files='/oracle12/app/oracle/oradata/db1/control01.ctl','/oracle12/app/oracle/oradata/db1/control02.ctl'
...
# 만약 mount단계로 진행되지 않을 경우
# 하나를 버리고 pfile모드로 기동
# 그 후, 회복 절차진행(복제 및 재등록)
```

### 3. open(default)

> **Data file, Redo log file**

data file, redo log file을 읽고 문제가 없다면 open 진행

## Shutdown

`shutdown [option]`

### 1. normal

> `default`

모든 세션이 소멸되어야 종료(무한대기)

추가적인 세션은 허용하지 않음

### 2. transactional

모든 트랜잭션(commit|rollback)이 소멸되어야 종료(무한대기)

모든 세션의 소멸을 기다리지 않고 즉시 종료

### 3. immediate

> dirty buffer[^dirty buffer]의 내용을 수행 및 완료 후 종료

사용자의 작업을 강제로 종료

메모리의 데이터를 **디스크에 저장하고 안전하게 종료**

commit 되지않은 세션 데이터는 rollbac

commit된 데이터는 DB에 내려 쓰는 작업을 완료한 후 DB 종료

### 4. abort

> dirty buffer[^dirty buffer]의 내용을 수행하지 않고 종료
> 단, instance recovery 수행

메모리(db buffer cache)의 데이터를 **디스크에 저장하지 않고 즉시 종료**

DB 재기동시 아직 정리되지 않은 메모리 영역을 디스크에 저장하는 **instance recovery를 수행하지만 장담할 수 없음**(SMON[^SMON])

redo log buffer의 내용은 DB가 내려가기 전 안전하게 redo log file에 내려써짐(LGWR[^LGWR])

## Alter Step

> 다음 단계로 이동

`alter database [step]`

역방향으로는 이동할  수 없음(오직 shutdown 후 다시 진행)

# Test

**startup nomount**

```sql
SQL>startup nomount
SQL> select status from v$instance;

STATUS
------------
STARTED
SQL> show parameter pfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      /oracle12/app/oracle/product/1
                                                 2.2.0.1/db_1/dbs/spfiledb1.ora
```

**startup mount**

```sql
SQL>col name format a50;
SQL> select file#, name, status from v$datafile;

     FILE# NAME                                               STATUS
---------- -------------------------------------------------- -------
         1 /oracle12/app/oracle/oradata/db1/system01.dbf      SYSTEM
         2 /oracle12/app/oracle/oradata/db1/sysaux01.dbf      ONLINE
         3 /oracle12/app/oracle/oradata/db1/undotbs01.dbf     ONLINE
         4 /oracle12/app/oracle/oradata/db1/users01.dbf       ONLINE
```





---

[^Pinned Buffer]: commit 전, 변경여지가 있는 상태; 다른 사용자가 이미 사용하고 있는 Buffer Block으로 사용할 수 없음
[^Dirty Buffer]: commit 후, disk로 내려쓰지 않은 상태; 현재 작업은 진행되지 않지만 다른 사용자가 내용을 변경한 후 아직 데이터 파일에 변경된 내용을 저장하지 않은 Buffer
[^Free Buffer]: 사용되지 않았거나(Unused) 또는 Dirty Buffer 였다가 디스크로 저장이 되고 다시 재사용 가능하게 된 Block