# Dynamic SGA

- DB 운영중(재가동 없이) 메모리 변경 가능(`>= 9i`)
- 파라미터 파일이 동적파일관리 형태여야 가능(spfile)

## parameter files

- DBMS 기동 및 운영에 필요한 필수 파라미터 정보를 기록
- 유실시 DB 기동 불가
- spfile과 init이 둘 다 있으면 spfile이 우선순위를 가짐
- pfile 변경시 spfile 삭제하면 pfile로 DB 기동 가능
- 파라미터 환경을 변경하려면 DB는 재기동 되어야함.

### **파라미터 파일 위치**

```shell
cd ${ORACLE_HOME}/dbs
cd ${ORACLE_HOME}/dbs;ls | tr ":" "\n";

# result
hc_db1.dat
init.ora
lkDB1
orapwdb1
spfiledb1.ora
```

### 파라미터 파일 구분

|                | pfile;[^pfile] | spfile;[^spfile] |
| -------------- | -------------- | ---------------- |
| 파일 형식      | txt            | binary           |
| 수정 가능 여부 | O              | X                |
| 물리 파일 이름 | initdb1.ora    | spfiledb1.ora    |

### **파라미터 파일 환경 구분** 

| pfile(initdb1.ora) | spfile(spfiledb1.ora) | 환경 구분 | 기동 가능 여부 |
| ------------------ | --------------------- | :-------: | :------------: |
| O                  | O                     |  spfile   |       O        |
| X                  | O                     |  spfile   |       O        |
| O                  | X                     |   pfile   |       O        |
| X                  | X                     |     X     |       X        |

### DB running pseudo code

> DB 기동과 parameter files와의 상관 절차
>
> spfile과 pfile이 둘 다 있으면 spfile이 우선순위를 가짐.

```shell
if spfile exist: # high priority
  nomount()
if pfile exist:  # low priority
  nomount()
error() 
```

### parameter file 유실 상황

```sql
SQL> startup
ORA-01078: failure in processing system parameters
LRM-00109: could not open parameter file '/oracle12/app/oracle/product/12.2.0.1/db_1/dbs/initdb1.ora'

SQL> select status from v$instance;
select status from v$instance
*
ERROR at line 1:
ORA-01034: ORACLE not available
Process ID: 0
Session ID: 0 Serial number: 0
```

# Test

## 환경 스위칭: pfile -> spfile

**0. 파라미터 파일 디렉토리 확인**

```shell
cd ${ORACLE_HOME}/dbs;ls | tr ":" "\n";
```

**1. 현재 파라미터 현황 확인**

```sql
SQL> show parameter pfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      /oracle12/app/oracle/product/1
                                                 2.2.0.1/db_1/dbs/spfiledb1.ora
```

**2. spfile -> pfile 생성**

```sql
SQL> create pfile from spfile;

File created.
```

**3. spfile 백업 및 삭제**

```shell
cp spfiledb1.ora spfiledb1.ora.back_$(date +"%Y-%m-%d_%H:%M:%S")
rm spfiledb1.ora
```

**4. DB 재기동 및 확인**

```sql
SQL> shutdown immediate;
SQL> startup;
SQL> select status from v$instance;
STATUS
------------
OPEN
SQL> show parameter pfile;
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string
```



# 🎁tip

**운영 중 수정불가한 spfile을 텍스트파일로 내려받아 주기적으로 보관해두어야 장애 대처시 도움**

**메모리 동적 변경 작업 수행 시나리오(spfile 환경)**

```shell
# 1. parameter file 백업
cp initdb1.ora initdb1.ora.back_$(date +"%Y-%m-%d_%H:%M:%S")
cp spfiledb1.ora spfiledb1.ora.back_$(date +"%Y-%m-%d_%H:%M:%S")

# 2. pfile 생성
SQL> create pfile from spfile;

# 3. 메모리 변경
SQL> alter system ...
```



# foot notes

[^pfile]: **P**arameter **FILE**
[^spfile]: **S**erver **P**arameter **FILE**(**default**)
[^oracle start up flow]: closed -> no mount -> mount -> open