# Control File

> 데이터베이스 구성 정보

## 특징

controlfile의 위치는 parameter file에 있음

변경시 parameter file을 변경해야함.

- pfile) 직접 수정 후, DB Open
- spfile) 명령어로 수정 가능(parameter file에 기록만 하고 실제로 물리적인 변경은 일어나지 않음)

binary file이므로 열거나 수정할 경우 conflict 발생여지 있으므로 건들지말 것

잃어버리면 모든게 끝남. -> 🔥**다중화 필요** -> DB 생성시 기본적으로 controlfile생성(최초 2개 생성) -> DB 기동에는 단 하나의 controlfile만 존재해도 open 가능 -> 모든 controlfile은 동일

global checkpoint[^global checkpoint] 발생시 controlfile, logfile, datafile의 시점을 일치시킴

## Practice

### 컨트롤 파일 추가(**spfile 환경**)

- [ ] **1. controlfile 확인**

```sql
SQL> col name format a30;
SQL> select * from v$controlfile;

STATUS  NAME                                           IS_ BLOCK_SIZE FILE_SIZE_BLKS     CON_ID
------- ---------------------------------------------- --- ---------- -------------- ----------
        /oracle12/app/oracle/oradata/db1/control01.ctl NO       16384            646          0
        /oracle12/app/oracle/oradata/db1/control02.ctl NO       16384            646          0
```

- [ ] **2. spfile 백업 및 확인, pfile 백업** 

```sql
SQL>show parameter pfile;
cd /oracle12/app/oracle/product/12.2.0.1/db_1/dbs
cp initdb1.ora initdb1.ora.back_$(date +"%Y-%m-%d_%H:%M:%S")
cp spfiledb1.ora spfiledb1.ora.back_$(date +"%Y-%m-%d_%H:%M:%S")
vi spfiledb1.ora

*.control_files='/oracle12/app/oracle/oradata/db1/control01.ctl','/oracle12/app/oracle/oradata/db1/control02.ctl'
```

- [ ] **3. parameter file 기록 수정 및 수정된 spfile로부터 pfile 생성**

```sql
alter system set control_files = '/oracle12/app/oracle/oradata/db1/control01.ctl','/oracle12/app/oracle/oradata/db1/control02.ctl','/oracle12/app/oracle/oradata/db1/control03.ctl' scope=spfile;

create pfile from spfile;
```

- [ ] **4. parameter file 확인**

```shell
vi /oracle12/app/oracle/product/12.2.0.1/db_1/dbs/spfiledb1.ora

*.control_files='/oracle12/app/oracle/oradata/db1/control01.ctl','/oracle12/app/oracle/oradata/db1/control02.ctl','/oracle12/app/oracle/oradata/db1/control03.ctl'
```

- [ ] **5. db shutdown** 

```sql
SQL>shutdown immediate;
```

- [ ] **6. control file 생성**

```shell
cd /oracle12/app/oracle/oradata/db1/
cp control01.ctl control03.ctl
```

- [ ] **7. db start**

```sql
SQL>startup;
```

- [ ] **8. control file 확인**

```sql
SQL> col name format a30;
SQL> select * from v$controlfile;

STATUS  NAME                                           IS_ BLOCK_SIZE FILE_SIZE_BLKS     CON_ID
------- ---------------------------------------------- --- ---------- -------------- ----------
        /oracle12/app/oracle/oradata/db1/control01.ctl NO       16384            646          0
        /oracle12/app/oracle/oradata/db1/control02.ctl NO       16384            646          0
        /oracle12/app/oracle/oradata/db1/control03.ctl NO       16384            646          0  -- 추가 확인 완료
```

### 컨트롤 파일 추가(**spfile환경에서 pfile환경으로 스위칭 후**)

> spfile -> pfile -> spfile

- [ ] **0. 기존 pfile, spfile 백업**

```shell
cd ${ORACLE_HOME}/dbs
cp initdb1.ora initdb1.ora.back_$(date +"%Y-%m-%d_%H:%M:%S")
cp spfiledb1.ora spfiledb1.ora.back_$(date +"%Y-%m-%d_%H:%M:%S")
```

- [ ] **1. 현재 spfile을 pfile로 생성**

```sql
SQL>create pfile from spfile;
```

- [ ] **2. shutdown**

```sql
SQL>shutdown immediate;
```

- [ ] **3. spfile 삭제**

```shell
cd ${ORACLE_HOME}/dbs
rm spfiledb1.ora
```

- [ ] **4. parameter file 수정**

```shell
cd ${ORACLE_HOME}/dbs
vi initdb1.ora

# ASIS
*.control_files='/oracle12/app/oracle/oradata/db1/control01.ctl','/oracle12/app/oracle/oradata/db1/control02.ctl','/oracle12/app/oracle/oradata/db1/control03.ctl'

# TOBE
*.control_files='/oracle12/app/oracle/oradata/db1/control01.ctl','/oracle12/app/oracle/oradata/db1/control02.ctl','/oracle12/app/oracle/oradata/db1/control03.ctl', '/oracle12/app/oracle/oradata/db1/control04.ctl'
```

- [ ] **5. startup**

```sql
SQL> startup;
ORACLE instance started.

Total System Global Area 1660944384 bytes
Fixed Size                  8621376 bytes
Variable Size            1056965312 bytes
Database Buffers          587202560 bytes
Redo Buffers                8155136 bytes
ORA-00205: error in identifying control file, check alert log for more info
```

> nomount 상태 돌입
>
> ```shell
> 2023-07-11T15:30:26.966015+09:00
> ORA-00210: cannot open the specified control file
> ORA-00202: control file: '/oracle12/app/oracle/oradata/db1/control04.ctl'
> ORA-27037: unable to obtain file status
> Linux-x86_64 Error: 2: No such file or directory
> ```

- [ ] **6. controlfile 위치 이동 및 확인**

```shell
cd /oracle12/app/oracle/oradata/db1/
ll
total 2275004
-rw-r-----. 1 oracle oinstall  10600448 Jul 11 15:26 control01.ctl
-rw-r-----. 1 oracle oinstall  10600448 Jul 11 15:26 control02.ctl
-rw-r-----. 1 oracle oinstall  10600448 Jul 11 15:26 control03.ctl
-rw-r-----. 1 oracle oinstall 209715712 Jul 11 15:13 redo01.log
-rw-r-----. 1 oracle oinstall 209715712 Jul 11 15:26 redo02.log
-rw-r-----. 1 oracle oinstall 209715712 Jul 11 15:13 redo03.log
-rw-r-----. 1 oracle oinstall 576724992 Jul 11 15:26 sysaux01.dbf
-rw-r-----. 1 oracle oinstall 734011392 Jul 11 15:26 system01.dbf
-rw-r-----. 1 oracle oinstall  20979712 Jul  7 16:00 temp01.dbf
-rw-r-----. 1 oracle oinstall 351281152 Jul 11 15:26 undotbs01.dbf
-rw-r-----. 1 oracle oinstall   5251072 Jul 11 15:26 users01.dbf
cp control03.ctl control04.ctl
```

- [ ] **7. alter || shutdown & startup**

```sql
SQL>alter database mount;
SQL>alter database open;
SQL> select status from v$instance;

STATUS
------------
OPEN
```

- [ ] **8. 환경스위칭 pfile -> spfile**

```sql
SQL> show parameter pfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string


SQL> create spfile from pfile;
SQL> exit;

cd ${ORACLE_HOME}/dbs
rm spfiledb1.ora.back_2023???

SQL> shutdown immediate;
SQL> exit;

cd ${ORACLE_HOME}/dbs
cp spfiledb1.ora spfiledb1.ora.back_$(date +"%Y-%m-%d_%H:%M:%S")

SQL> startup;
SQL> select status from v$instance;

STATUS
------------
OPEN

SQL> show parameter pfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      /oracle12/app/oracle/product/1
                                                 2.2.0.1/db_1/dbs/spfiledb1.ora
```

---

# foot note

[^global checkpoint]: shutdown immediate시 발생, checkpoint는 가장 강력한 동기 신호
