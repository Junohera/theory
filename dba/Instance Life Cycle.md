[toc]

# Instance Life Cycle

<img src="./assets/Oracle Life Cycle.png" alt="Oracle Life Cycle" style="zoom: 50%;" />

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

한단계씩 변경 가능(ex: nomount -> open 불가)

## Instance recovery ✨

- shutdown abort로 중지했거나 기타 여러 이유로 DB가 비정상 종료된 경우 발생
- 메모리의 정보를 아직 디스크에 완전하게 내려쓰지 못하여 시점정보가 불일치하므로 이를 일치시켜주는 작업
- SMON[^SMON]이 수행
- mount 단계에서 수행

**flow**

1. roll forward
2. open
3. roll backward

**example**

1. 사용자 A가 홍길동 -> 일지매로 변경
2. 사용자 A가 commit을 수행하여 변경내용이 redolog buffer에 기록(바로 disk에 I/O하지 않고, 버퍼에 기록)
3. 사용자 B가 박길동 -> 최길동으로 변경
4. 사용자 B는 commit X, redolog buffer에 기록
5. shutdown abort -> redolog buffer의 내용이 redolog file에 기록
   (아직 db buffer cache 내용은 datafile에 내려쓰지 못한 시점)
   메모리는 정리
6. startup
   mount 단계에서 redolog file과 datafile의 시점 확인하여 불일치할 경우
   redologfile의 미래시점으로 datafile의 시점을 roll forward(commit된 정보만 빠르게 datafile에 기록)
   변경된 작업의 모든 적용 -> 시점정보 일치 -> open
   open 후 rollback이 필요한 데이터에 대해 반영(undo segment에서의 과거 이미지 기록 정보 반환)

# Practice

## startup

**startup nomount**

```sql
SQL>startup nomount;
SQL>select status from v$instance;

STATUS
------------
STARTED

SQL>show parameter pfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      /oracle12/app/oracle/product/1
                                                 2.2.0.1/db_1/dbs/spfiledb1.ora
```

**startup mount**

```sql
SQL>startup mount;
SQL>select status from v$instance;

STATUS
------------
MOUNTED

SQL>col name format a50;
SQL>select file#, name, status from v$datafile;

     FILE# NAME                                               STATUS
---------- -------------------------------------------------- -------
         1 /oracle12/app/oracle/oradata/db1/system01.dbf      SYSTEM
         2 /oracle12/app/oracle/oradata/db1/sysaux01.dbf      ONLINE
         3 /oracle12/app/oracle/oradata/db1/undotbs01.dbf     ONLINE
         4 /oracle12/app/oracle/oradata/db1/users01.dbf       ONLINE
```

**startup [open]**

```sql
SQL>startup open;
SQL>select status from v$instance;

STATUS
------------
OPEN
```

## alter database [step]

**nomount -> mount**

```sql
SQL>alter database mount;

Database altered.


SQL>select status from v$instance;

STATUS
------------
MOUNTED

SQL>select file#, name, status from v$datafile;

     FILE# NAME                                               STATUS
---------- -------------------------------------------------- -------
         1 /oracle12/app/oracle/oradata/db1/system01.dbf      SYSTEM
         2 /oracle12/app/oracle/oradata/db1/sysaux01.dbf      ONLINE
         3 /oracle12/app/oracle/oradata/db1/undotbs01.dbf     ONLINE
         4 /oracle12/app/oracle/oradata/db1/users01.dbf       ONLINE
```

**nomount -> ~~mount~~ -> open**

```sql
-- failure: nomount -> open
SQL>alter database open;
alter database open
*
ERROR at line 1:
ORA-01507: database not mounted

-- success: nomount -> mount -> open
SQL>alter database mount;
SQL>select status from v$instance;

STATUS
------------
MOUNTED

SQL>alter database open;

Database altered.

SQL>select status from v$instance;

STATUS
------------
OPEN
```

```sql
closed			->			nomount			->			mount			->			open

			✅ parameter file
			
			1) 메모리 정보 --->|
			2) controlfile 위치 ---------------->|
			
													✅ controlfile read
													
													1) datafile 정보 |----------------->|
													2) redo 정보 		 |----------------->|
			
** controlfile 정보 수정 -> parameterfile 수정
	1) pfile : 직접 수정
	2) spfile : 명령어로 수정
		alter system set ... scope=pfile|spfile;
		
** datafile, redolog 정보 수정 -> controlfile 수정(only command)
	alter database add datafile ...;
	alter database add logfile ...;
	
case1) old parameter file로 DB 기동시
result)	instance 구성은 과거버전으로 기동될 수 있지만
		 		controlfile 정보가 동일하다면
		 		database 구성은 최신정보로 기동됨
		 		
		 		pfile(2023/1/20)			spfile(2023/7/21)
		 		memory_target=1G			memory_target=5G
								 		controlfile		
				datafile 			5				datafile				8
				redo					3				redo						6
		 
controlfile(7/19)							datafile, redo(7/21)
		원인) controlfile <-> datafile, redo 시점 불일치
		해결) controlfile 파일 시점을
				 datafile, redo 시점에 맞게 세팅(재생성)
				 ** noresetlogs
```

---

[^Pinned Buffer]: commit 전, 변경여지가 있는 상태; 다른 사용자가 이미 사용하고 있는 Buffer Block으로 사용할 수 없음
[^Dirty Buffer]: commit 후, disk로 내려쓰지 않은 상태; 현재 작업은 진행되지 않지만 다른 사용자가 내용을 변경한 후 아직 데이터 파일에 변경된 내용을 저장하지 않은 Buffer
[^Free Buffer]: 사용되지 않았거나(Unused) 또는 Dirty Buffer 였다가 디스크로 저장이 되고 다시 재사용 가능하게 된 Block

