[toc]

# Export

oracle에서 제공하는 논리적 백업 및 적재, 이관 툴(버전, 플랫폼이 다른 경우 지원)
exp로 논리 백업 수행(테이블/스키마/테이블스페이스/전체 단위)
imp로 데이터 적재(모든 오브젝트 적재 가능(exp mode에 따라 달라짐))

```shell
exp -help
Keyword    Description (Default)      Keyword      Description (Default)
--------------------------------------------------------------------------
USERID     username/password          FULL         export entire file (N)
BUFFER     size of data buffer        OWNER        list of owner usernames
FILE       output files (EXPDAT.DMP)  TABLES       list of table names
COMPRESS   import into one extent (Y) RECORDLENGTH length of IO record
GRANTS     export grants (Y)          INCTYPE      incremental export type
INDEXES    export indexes (Y)         RECORD       track incr. export (Y)
DIRECT     direct path (N)            TRIGGERS     export triggers (Y)
LOG        log file of screen output  STATISTICS   analyze objects (ESTIMATE)
ROWS       export data rows (Y)       PARFILE      parameter filename
CONSISTENT cross-table consistency(N) CONSTRAINTS  export constraints (Y)
```

```shell
exp system/oracle file=${OUTPUT_PATH} tables=(...)|owner=(...)|full=(Y|N)
exp system/oracle file=${OUTPUT_PATH} tables=table
exp system/oracle file=${OUTPUT_PATH} owner=user
exp system/oracle file=${OUTPUT_PATH} full=Y
```

# Import

- imp시에는 가급적 exp유저와 동일한 환경 구성, 동일한 유저로 imp하길 권장
- 논리적 적재 방식이므로 데이터파일까지 적재하지 않고,
  imp시에는 가급적 exp DB와 동일한 테이블스페이스와 데이터파일을 미리 생성하도록 할 것
- 만약 imp시에 exp시 테이블스페이스가 존재하지 않을 경우
  imp table owner의 default tablespace에 저장됨.👻

```shell
imp -help

Import: Release 12.2.0.1.0 - Production on Tue Aug 1 14:36:40 2023

Copyright (c) 1982, 2017, Oracle and/or its affiliates.  All rights reserved.



You can let Import prompt you for parameters by entering the IMP
command followed by your username/password:

     Example: IMP SCOTT/TIGER

Or, you can control how Import runs by entering the IMP command followed
by various arguments. To specify parameters, you use keywords:

     Format:  IMP KEYWORD=value or KEYWORD=(value1,value2,...,valueN)
     Example: IMP SCOTT/TIGER IGNORE=Y TABLES=(EMP,DEPT) FULL=N
               or TABLES=(T1:P1,T1:P2), if T1 is partitioned table

USERID must be the first parameter on the command line.

Keyword  Description (Default)       Keyword      Description (Default)
--------------------------------------------------------------------------
USERID   username/password           FULL         import entire file (N)
BUFFER   size of data buffer         FROMUSER     list of owner usernames
FILE     input files (EXPDAT.DMP)    TOUSER       list of usernames
SHOW     just list file contents (N) TABLES       list of table names
IGNORE   ignore create errors (N)    RECORDLENGTH length of IO record
GRANTS   import grants (Y)           INCTYPE      incremental import type
INDEXES  import indexes (Y)          COMMIT       commit array insert (N)
ROWS     import data rows (Y)        PARFILE      parameter filename
LOG      log file of screen output   CONSTRAINTS  import constraints (Y)
DESTROY                overwrite tablespace data file (N)
INDEXFILE              write table/index info to specified file
SKIP_UNUSABLE_INDEXES  skip maintenance of unusable indexes (N)
FEEDBACK               display progress every x rows(0)
TOID_NOVALIDATE        skip validation of specified type ids
FILESIZE               maximum size of each dump file
STATISTICS             import precomputed statistics (always)
RESUMABLE              suspend when a space related error is encountered(N)
RESUMABLE_NAME         text string used to identify resumable statement
RESUMABLE_TIMEOUT      wait time for RESUMABLE
COMPILE                compile procedures, packages, and functions (Y)
STREAMS_CONFIGURATION  import streams general metadata (Y)
STREAMS_INSTANTIATION  import streams instantiation metadata (N)
DATA_ONLY              import only data (N)
VOLSIZE                number of bytes in file on each volume of a file on tape

The following keywords only apply to transportable tablespaces
TRANSPORT_TABLESPACE import transportable tablespace metadata (N)
TABLESPACES tablespaces to be transported into database
DATAFILES datafiles to be transported into database
TTS_OWNERS users that own data in the transportable tablespace set
```

```shell
imp username/password file=${INPUT_PATH} tables=(...)|touser=(...)|fromuser=(...)|full=Y|N
imp username/password file=${INPUT_PATH} tables=table
imp username/password file=${INPUT_PATH} touser=user
imp username/password file=${INPUT_PATH} fromuser=fromuser
imp username/password file=${INPUT_PATH} full=Y|N
```



---

# details

> https://docs.oracle.com/cd/A97630_01/server.920/a96652/ch01.htm

| Object                                        | Table                                                        | User (Schema)                                                | Tablespace | Full                                                         |
| --------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ---------- | ------------------------------------------------------------ |
| Analyze tables/statistics                     | Yes                                                          | Yes                                                          | Yes        | Yes                                                          |
| B-tree, bitmap, domain functional indexes     | [Yes](https://docs.oracle.com/cd/A97630_01/server.920/a96652/ch01.htm#1005006)[Foot 1](https://docs.oracle.com/cd/A97630_01/server.920/a96652/ch01.htm#1005006) | [Yes](https://docs.oracle.com/cd/A97630_01/server.920/a96652/ch01.htm#1005006)[Footref 1](https://docs.oracle.com/cd/A97630_01/server.920/a96652/ch01.htm#1005006) | Yes        | Yes                                                          |
| Database links                                | No                                                           | Yes                                                          | No         | Yes                                                          |
| External tables (without data)                | Yes                                                          | Yes                                                          | No         | Yes                                                          |
| Indexes owned by users other than table owner | Yes (Privileged users only)                                  | Yes                                                          | Yes        | Yes                                                          |
| Index types                                   | No                                                           | Yes                                                          | No         | Yes                                                          |
| Object grants                                 | Yes (Only for tables and indexes)                            | Yes                                                          | Yes        | Yes                                                          |
| Object type definitions used by table         | Yes                                                          | Yes                                                          | Yes        | Yes                                                          |
| Object types                                  | No                                                           | Yes                                                          | No         | Yes                                                          |
| Private synonyms                              | No                                                           | Yes                                                          | No         | Yes                                                          |
| Profiles                                      | No                                                           | No                                                           | No         | Yes                                                          |
| Public synonyms                               | No                                                           | No                                                           | No         | Yes                                                          |
| Referential integrity constraints             | Yes                                                          | Yes                                                          | No         | Yes                                                          |
| Role grants                                   | No                                                           | No                                                           | No         | Yes                                                          |
| Roles                                         | No                                                           | No                                                           | No         | Yes                                                          |
| Sequence numbers                              | No                                                           | Yes                                                          | No         | Yes                                                          |
| System privilege grants                       | No                                                           | No                                                           | No         | Yes                                                          |
| Table constraints (primary, unique, check)    | Yes                                                          | Yes                                                          | Yes        | Yes                                                          |
| Table data                                    | Yes                                                          | Yes                                                          | No         | Yes                                                          |
| Tablespace quotas                             | No                                                           | No                                                           | No         | Yes                                                          |
| Triggers                                      | Yes                                                          | [Yes](https://docs.oracle.com/cd/A97630_01/server.920/a96652/ch01.htm#1005466)[Foot 2](https://docs.oracle.com/cd/A97630_01/server.920/a96652/ch01.htm#1005466) | Yes        | [Yes](https://docs.oracle.com/cd/A97630_01/server.920/a96652/ch01.htm#1015191)[Foot 3](https://docs.oracle.com/cd/A97630_01/server.920/a96652/ch01.htm#1015191) |
| Triggers owned by other users                 | Yes (Privileged users only)                                  | No                                                           | No         | No                                                           |
| User definitions                              | No                                                           | No                                                           | No         | Yes                                                          |
| User views                                    | No                                                           | Yes                                                          | No         | Yes                                                          |

## 