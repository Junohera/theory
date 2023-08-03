[toc]

# Summary - Dump



## datapump

>= 10g 
>migration tool
>기존 exp/imp는 반드시 os를 거쳐야하는 방식이므로 보안상 문제발생여지 존재
>다양한 기능, 빠른 속도 지원(parallel 처리 가능)
>작업중단 이후, 연속적으로 작업 가능
>작업 시간 예상

### case

1) local에서의 exp를 통한 dump파일을 target 서버에 전송 후, imp
2) target 서버에서 local 서버로 원격exp 후, dump파일을 imp

### setup

```sql
select *
  from dba_directories;
  
OS working directory
mkdir -p /oracle/home/datapump
chown oracle:oinstall /oracle/home/datapump

SQL> create or replace directory datapump as '/oracle/home/datapump';
Directory created.

SQL> grant read, write on directory datapump to scott;
Grant succeeded.

SQL> exec dbms_metadata_util.load_stylesheets;
PL/SQL procedure successfully completed.
```

### mode

1. table
2. schema
3. tablespace