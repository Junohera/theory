[toc]

# Datafile

> physical storage(=🧱)

## 관리

### 1. tablespace 조회

```sql
select *
  from dba_tablespaces;
  
TABLESPACE_NAME
------------------------------
SYSTEM
SYSAUX
UNDOTBS1
TEMP
USERS
```

### 2. tablespace를 구성하는 datafiles 조회

```sql
select FILE_NAME,
			 TABLESPACE_NAME,
			 BYTES/1024/1024 AS "BYTES(MB)",		-- 실제 사용량
			 AUTOEXTENSIBLE,										-- 자동 증가여부
			 MAXBYTES/1024/1024 AS "BYTES(MB)"	-- 최대허용사용량
  from dba_data_files; -- temp tablespaces 제외한 모든 datafile
  
------------------------------------------------------------------------------------------------
FILE_NAME																					 TABLESPACE_NAME  BYTES(MB)   AUT  BYTES(MB)
-------------------------------------------------- --------------- 	----------- ---  -----------
/oracle12/app/oracle/oradata/db1/system01.dbf				SYSTEM          700 			  YES  32767.9844
/oracle12/app/oracle/oradata/db1/sysaux01.dbf				SYSAUX          550 			  YES  32767.9844
/oracle12/app/oracle/oradata/db1/undotbs01.dbf			UNDOTBS1        335 			  YES  32767.9844
/oracle12/app/oracle/oradata/db1/users01.dbf				USERS             5 			  YES  32767.9844
```

### 3. temp tablespace를 구성하는 datafiles 조회

```sql
select FILE_NAME,
			 TABLESPACE_NAME,
			 BYTES/1024/1024 AS "BYTES(MB)",		-- 실제 사용량
			 AUTOEXTENSIBLE,										-- 자동 증가여부
			 MAXBYTES/1024/1024 AS "BYTES(MB)"	-- 최대허용사용량
  from dba_temp_files; -- temp tablespaces의 모든 datafile

------------------------------------------------------------------------------------------------
FILE_NAME																					 TABLESPACE_NAME  BYTES(MB)   AUT  BYTES(MB)
-------------------------------------------------- --------------- 	----------- ---  -----------
/oracle12/app/oracle/oradata/db1/temp01.dbf        TEMP             20          YES  32767.9844
```

### 4. add✨

```sql
alter tablespace class1 
      add datafile '/oracle12/app/oracle/oradata/db1/class1_02.dbf' size 1m;
```

### 5. resize

```sql
alter database datafile '/oracle12/app/oracle/oradata/db1/class1_01.dbf' resize 2m;
```

### 6. autoextend

```sql
alter database datafile '/oracle12/app/oracle/oradata/db1/class1_02.dbf' autoextend on;
```

### 7. rename✨

- 주로 디스크의 **물리적 이동이 필요할 경우** 사용
  (디스크가 문제가 있거나 용량이 부족하여 다른 디스크로 이동해야할 경우)
- datafile **online중 물리적 복사 또는 이동 금지**
- tablespace를 `offline | shutdown` 한 후 작업 필요
- offline이 불가능한 system, undo, temp 등은 shutdown 후 처리

| datafile 물리적 이동 | online 가능 여부 | 절차                                                         |
| -------------------- | ---------------- | ------------------------------------------------------------ |
| SYSTEM               | ❌                | shutdown -> physical move -> startup mount -> logical move -> alter database open |
| SYSAUX               | ❌                | shutdown -> physical move -> startup mount -> logical move -> alter database open |
| UNDOTBS1             | ❌                | shutdown -> physical move -> startup mount -> logical move -> alter database open |
| USERS                | ✅                | tablespace offline -> physical move -> logical move -> tablespace online |
| `user define`        | ✅                | tablespace offline -> physical move -> logical move -> tablespace online |

```sql
alter database rename file '/oracle12/app/oracle/oradata/db1/class1_02.dbf' to '/home/oracle/oradata/db1/class1_02.dbf';
```

### 8. delete

- default tablespace(system, sysaux, undo, temp) 삭제 불가
- table이 존재하는 경우, 삭제불가(including contents 옵션으로 데이터와 함께 삭제)
- OS 데이터파일 그대로 남아있음

```sql
# logical delete
drop tablespace class1;											-- 테이블이 존재하므로 제거 불가능
drop tablespace class1 including contents; 	-- 테이블이 존재함에도 제거 가능

# physical delete
rm class1_01.dbf class1_02.dbf ...
```



