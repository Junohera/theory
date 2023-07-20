# Temporary tablespace

## 특징

- **2차 정렬**을 위한 공간(in disk)
  - 1차적으로 PGA에서 정렬 후, 할당된 PGA의 사이즈보다 큰 사이즈의 정렬 수행 필요시 이 공간에서 수행(in disk)
  - 해당 tablespace에 할당받은 datafile(disk)의 가용영역이 없을 경우, 조회되지 않거나 정렬이 수행되지 않음
- 여러 temporary tablespace 생성 가능하지만 default temporary tablespace를 반드시 1개 유지해야함
  - default temporary tablespace 삭제 불가
  - ✅user별로 temporary tablespace 분리 권고
    - user별로 temporary tablespace를 지정하지 않으면 연관되지 않은 업무에서의 조회로 인해 다른 업무의 조회도 조회되지 않음.



## 조회

### 1. physical temporary tablespace --> temp files

```sql
select tablespace_name,
		   file_name,
		   bytes
	from dba_temp_files;
```

### 2. default temporary tablespace

```sql
select property_value
  from database_properties
 where property_name = 'DEFAULT_TEMP_TABLESPACE';
```

### 3. temporary tablespace by user

```sql
select USERNAME,
       DEFAULT_TABLESPACE, 
       TEMPORARY_TABLESPACE
  from dba_users;
```

### 4. check free space in temporary tablespace

```sql
select tablespace_name,
       round(allocated_space/1024/1042,2) as alloc_mb,
       round(decode(sign(allocated_space-free_space), -1, 0, 
       allocated_space-free_space)/1024/1024,2) as used_mb,
       round(free_space/1024/1024,2) as free_mb,
       round(decode(sign(allocated_space-free_space), -1, 0, 
       allocated_space-free_space)/allocated_space*100,2) as "used(%)" 
from dba_temp_free_space;
```

## 관리

### 1. size 조회

```sql
select owner,
			 segment_name,
			 segment_type,
			 sum(bytes)/1024/1024 "mb"
	from dba_segments
where 1=1
		  -- and segment_type like 'TEMP%'
group by owner, segment_name, segment_type;
```

```sql
select TABLESPACE_NAME,
       FILE_NAME, 
       BYTES/1024/1024 "mb",
       AUTOEXTENSIBLE
  from dba_temp_files;
```

```sql
select property_value
  from database_properties
 where property_name = 'DEFAULT_TEMP_TABLESPACE';
```

### 2. 생성

```sql
create temporary tablespace temp2
       tempfile '/oracle12/app/oracle/oradata/db1/temp02.dbf' size 50m;
```

### 3. resize

```sql
alter database tempfile '/oracle12/app/oracle/oradata/db1/temp02.dbf' resize 60m;
```

### 4. add

```sql
alter tablespace temp2
			add tempfile '/oracle12/app/oracle/oradata/db1/temp02_1.dbf' size 10m;
```

### 5. autoextend on

```sql
alter tempfile '/oracle12/app/oracle/oradata/db1/temp03.dbf' autoextend on;
```

### 6. default temporary tablespace 생성

```sql
alter database default temporary tablespace temp2;
```

### 7. user별로 temporary tablespace 변경✅

```sql
alter user scott temporary tablespace temp2;
```

### 8. temp tablespace 삭제

```sql
drop tablespace temp;
```





## default 변경



## 유저 생성시

```sql
create user ${USER_NAME} identified by ${PASSWORD}
default tablespace ...
default temporary tablespace ...
;
```

