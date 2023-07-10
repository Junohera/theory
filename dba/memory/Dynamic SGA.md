# Dynamic SGA

- DB 운영중(재가동 없이) 메모리 변경 가능(`>= 9i`)
- 파라미터 파일이 동적파일관리 형태여야 가능(spfile)
- 메모리의 변경은 granule[^granule] 단위로 변경됨
  -  `SGA < 1G`?`4MB`:`16MB`

- 자동 메모리 관리(ASMM[^ASMM] or AMM[^AMM]) 기능이 활성화되어 있을 경우 동적 메모리 변경 대상은 최소 사이즈를 의미함
- alter system set 명령어로 파라미터 변경 가능(`with scope option`)

---

## Parameters

| key              | label                | is dynamic | description                                                  |
| ---------------- | -------------------- | ---------- | ------------------------------------------------------------ |
| memory_target    |                      | false      |                                                              |
| sga_max_size     |                      | false      | v$sga_dynamic_free_memory를 통해 SGA의 가용영역을 확인 후, 변경 |
| sga_target       |                      | false      |                                                              |
| log_buffer       | redo log buffer size | false      |                                                              |
| db_cache_size    |                      | true       |                                                              |
| shared_pool_size |                      | true       |                                                              |
| java_pool_size   |                      | true       |                                                              |
| large_pool_size  |                      | true       |                                                              |

## Scope

> 동적 메모리 변경시 사용되는 옵션

| 이름            | 내용                                                      | 범위                | 정적 파라미터 변경 가능 여부 |
| --------------- | --------------------------------------------------------- | ------------------- | ---------------------------- |
| memory          | 현 메모리에서만 변경(DB 재기동시 원래값으로 돌아감)       | 다음 재기동 전      | false                        |
| spfile          | parameter file에만 기록하고 현 메모리에서는 변경되지 않음 | 재기동부터          | true                         |
| both(`default`) | 메모리도 변경, parameter file에도 기록                    | 지금부터 재기동까지 | false                        |

## parameter files

- DBMS 기동 및 운영에 필요한 필수 파라미터 정보를 기록
- 유실시 DB 기동 불가
- spfile[^spfile]과 init이 둘 다 있으면 spfile이 우선순위를 가짐
- pfile[^pfile] 변경시 spfile 삭제하면 pfile로 DB 기동 가능
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

| pfile | spfile | 환경 구분 | 기동 가능 여부 |
| ----- | ------ | :-------: | :------------: |
| O     | O      |  spfile   |       O        |
| X     | O      |  spfile   |       O        |
| O     | X      |   pfile   |       O        |
| X     | X      |     X     |       X        |

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

## startup시 SGA 영역 조회

```shell
SQL> startup;
ORACLE instance started.

Total System Global Area 1660944384 bytes
Fixed Size                  8621376 bytes
Variable Size            1056965312 bytes
Database Buffers          587202560 bytes
Redo Buffers                8155136 bytes
Database mounted.
Database opened.
SQL> select 1660944384 / 1024 / 1024 as "System Global Area(MB)" from dual;

System Global Area(MB)
----------------------
                  1584
```

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

> 반대로, pfile에서 spfile로도 생성이 가능
>
> ```sql
> create spfile from pfile;
> ```

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

## java pool size 변경

**환경**

- AMM[^AMM]
- java_pool_size는 최소 메모리 할당값을 의미

**0. 메모리 확인**

```sql
select *
  from v$parameter
 where name in ('memory_target',
                'sga_max_size',
                'sga_target',
                'shared_pool_size',
                'java_pool_size');
                
select pool,
       round(sum(bytes)/1024/1024, 2) as "size(MB)"
  from v$sgastat
 group by pool;
```

**1. 메모리 동적 변경 및 확인**

```sql
-- 현 메모리에서만 적용
alter system set java_pool_size = 33M scope = memory;

-- 확인
select pool,
       round(sum(bytes)/1024/1024, 2) as "size(MB)"
  from v$sgastat
 group by pool;
 
-- 결과
java pool	48

-- 결론
-- java_pool_size가 33M가 아닌 48M로 변경됨(기존에는 32M였음)
-- 따라서 granule이 16M임을 알 수 있음
```

**2. 데이터베이스 재기동 및 재확인 **

> scope을 memory로 했으므로

```shell
SQL> shutdown immediate;
SQL> startup;

SQL> select pool,
       round(sum(bytes)/1024/1024, 2) as "size(MB)"
  from v$sgastat
  3    4   group by pool;

POOL             size(MB)
-------------- ----------
                      672
java pool              16
shared pool           208
large pool             32
```

**결과**

- scope의 memory옵션이었으므로 재기동시 기본값으로 복구
- java_pool_size가 16M로 복구
- 기본값은 16M

## sga_max_size 변경

**1. sga 확인**

```sql
select *
  from v$parameter
 where name in ('memory_target',
                'sga_max_size', -- 1568M
                'sga_target',
                'shared_pool_size',
                'java_pool_size');
```

**2. sga 남은 영역 확인**

```sql
select current_size/1024/1024 as "current_size(MB)"
  from v$sga_dynamic_free_memory;
  
current_size(MB)
----------------
             640
```

**3. memory옵션별로 1 granule만 증가**

- ASIS: 1568
- TOBE: 1584

~~3-1. memory 옵션으로 변경 -> 변경가능한 파라미터가 아니므로 변경 불가~~

1. 조회 및 변경시도
   ```sql
   select * from v$parameter where name = 'sga_max_size';
   
   141	sga_max_size	6	1644167168	1568M
   
   alter system set sga_max_size = 1584M scope = memory;
   
   ORA-02095: 지정된 초기화 매개변수를 수정할 수 없습니다.
   ```

~~3-2. both 옵션으로 변경 -> 변경가능한 파라미터가 아니므로 변경 불가~~ 

1. 조회 및 변경시도

   ```sql
   select * from v$parameter where name = 'sga_max_size';
   
   141	sga_max_size	6	1644167168	1568M
   
   alter system set sga_max_size = 1584M scope = both;
   
   ORA-02095: 지정된 초기화 매개변수를 수정할 수 없습니다.
   ```

3-3. spfile 옵션으로 변경

1. 조회
   ```sql
   select * from v$parameter where name = 'sga_max_size';
   
   141	sga_max_size	6	1644167168	1568M
   ```

2. 변경
   ```sql
   alter system set sga_max_size = 1584M scope = spfile;
   ```

3. 재기동 시도
   ```shell
   SQL>shutdown immediate;
   SQL> startup
   ORA-00844: Parameter not taking MEMORY_TARGET into account
   ORA-00851: SGA_MAX_SIZE 1660944384 cannot be set to more than MEMORY_TARGET 1644167168.
   ORA-01078: failure in processing system parameters
   
   -- 실패
   ```

4. trouble shooting

   > 🧨기동 실패 원인
   >
   > 에러: 
   > ORA-00844: Parameter not taking MEMORY_TARGET into account
   > ORA-00851: SGA_MAX_SIZE 1660944384 cannot be set to more than MEMORY_TARGET 1644167168.
   > ORA-01078: failure in processing system parameters
   >
   > 이유:
   >
   > sga_max_size > memory_target
   >
   > 설명:
   >
   > memory_target은 AMM의 메모리 사이즈
   > sga_max_size는 SGA의 메모리 사이즈
   >
   > AMM은 PGA+SGA를 관리하므로, memory_target은 (pga의 사이즈 + sga의 사이즈)보다 커야만 함.

   1. pfile 환경 기동

      1. memory_target을 증가(직접 설정할 수 있다면)
      2. 🎃앞으로 동적 파라미터를 변경할 필요가 절대 전혀 영원히 없다면
      3. 밑의 시나리오를 문제없이 수행가능하다면

      ```shell
      cd ${ORACLE_HOME}/dbs
      cp initdb1.ora initdb1.ora.back_$(date +"%Y-%m-%d_%H:%M:%S")
      vi initdb1.ora
      
      *.memory_target=1584m
      db1.__sga_target=0
      
      :wq
      
      cp spfiledb1.ora spfiledb1.ora.back_$(date +"%Y-%m-%d_%H:%M:%S")
      rm spfiledb1.ora
      
      SQL>startup;
      SQL> show parameter pfile;
      
      NAME                                 TYPE        VALUE
      ------------------------------------ ----------- ------------------------------
      spfile                               string
      
      -- pfile 환경으로 조회됨
      -- 이후, 동적변경이 필요한 환경일 경우 절대 변경 불가 -> 이로인해 불필요한 재기동 발생
      -- 그러므로, 다시 Dynamic SGA 상태에서 운용 가능하도록 변경
      
      -- pfile -> spfile환경으로 변경
      SQL>create spfile from pfile;
      SQL>shutdown immediate;
      SQL>startup;
      SQL> show parameter pfile;
      
      NAME                                 TYPE        VALUE
      ------------------------------------ ----------- ------------------------------
      spfile                               string      /oracle12/app/oracle/product/1
                                                       2.2.0.1/db_1/dbs/spfiledb1.ora
      
      -- spfile 환경으로 조회됨
      -- 이후, 동적변경이 필요한 경우 대응 가능해짐.
      -- Dynamic SGA 상태에서 운용 가능
      ```

   2. **spfile 환경 기동(원복)**

      1. backup spfile을 spfile로 복구
         ```shell
         cd ${ORACLE_HOME}/dbs
         cp spfiledb1.ora.back_2023-07-10_10\:39\:08 spfiledb1.ora
         sqlplus / as sysdba
         SQL>startup
         ```

         복구 확인 쿼리

         ```sql
         select * from v$parameter where name = 'sga_max_size';
         
         141	sga_max_size	6	1644167168	1568M
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

[^pfile]: **P**arameter **FILE**(initdb1.ora)
[^spfile]: **S**erver **P**arameter **FILE**(spfiledb1.ora)
[^oracle start up flow]: closed -> no mount -> mount -> open
[^ASMM]: Automatic Shared Memoery Management
[^AMM]: Automatic Memory Management
[^Granule]: **가상 메모리 내의 메모리 단위**, Dynamic SGA에서 할당 가능한 최소한의 단위

