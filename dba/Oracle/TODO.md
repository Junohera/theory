- [ ] DBA 관점 storage관리하기 위한 단위 등에 대해 정리 block, extent, segment, initial, next(to Storage.md)
  - [ ] segment

    - [ ] extent(8 block, =64K)
      - [ ] block(8K)

- [ ] process의 관계 도식화(to process.md)
- [ ] architecture 도식화(to oracle Architecture.md)
  - [ ] 구성도
  - [ ] 시퀀스다이어그램
- [ ] sql -> txt로 된 파일들의 필기 포맷 맞추기
- [ ] AMM, ASMM 다이어그램
- [ ] 이식성을 위해 DHCP를 유지하되, 가상 서버 환경을 주기적으로 on/off해야할 경우, ip 변경에 대한 대응마련(shell)
- [ ] instance recovery에 대해 도식화 순서도?
- [ ] process에 대해 생명주기를 sequence diagram으로 표현
- [ ] process의 관계(system, user, server)를 도식화
- [ ] 그룹에 멤버가 여러 개일 경우 병렬로 동시에 같은 내용을 기록하는데 멤버가 같은 디스크에 존재한다면 직렬로 기록하게 된다 Sequence Diagram
- [ ] tablespace류들 이해하도록 재정리
- [x] offlinebackup 작성
- [ ] 논리적으로 존재하는 datafile경로를 기준으로 존재하지 않는 파일들과 불필요하게 존재하는 파일 목록 조회(정리대상과 누락대상 확인하기 위한 스크립트)(+color)

```shell
cd;ls -l /oracle12/app/oracle/oradata/db1/*.dbf | awk -F" " '{print $NF}'
 
/oracle12/app/oracle/oradata/db1/sysaux01.dbf
/oracle12/app/oracle/oradata/db1/system01.dbf
/oracle12/app/oracle/oradata/db1/temp01.dbf
/oracle12/app/oracle/oradata/db1/test2_01.dbf
/oracle12/app/oracle/oradata/db1/undotbs01.dbf
/oracle12/app/oracle/oradata/db1/users01.dbf
/oracle12/app/oracle/oradata/db1/users02.dbf

```



```sql
with
LOGICAL as (
  select file_id,
         file_name,
         tablespace_name
    from dba_data_files
   order by file_id
),
PHYSICAL as (
  select row_number() over(order by file_name desc) as file_id,
         file_name,
         null
    from (select null as file_name from dual
           union all select '/oracle12/app/oracle/oradata/db1/sysaux01.dbf' from dual
           union all select '/oracle12/app/oracle/oradata/db1/system01.dbf' from dual
           union all select '/oracle12/app/oracle/oradata/db1/temp01.dbf' from dual
           union all select '/oracle12/app/oracle/oradata/db1/test2_01.dbf' from dual
           union all select '/oracle12/app/oracle/oradata/db1/undotbs01.dbf' from dual
           union all select '/oracle12/app/oracle/oradata/db1/users01.dbf' from dual
           union all select '/oracle12/app/oracle/oradata/db1/users02.dbf' from dual
           union all select '/oracle12/app/oracle/oradata/db1/users03.dbf' from dual)
   where file_name is not null
),
MISSING as (
  select 'MISSING' as type,
         file_name
    from (select file_name from LOGICAL
           minus
          select file_name from PHYSICAL)
),
CLEANING as (
  select 'CLEANING' as type,
         file_name
    from (select file_name from PHYSICAL
           minus
          select file_name from LOGICAL)
),
result as (
  select type, file_name from MISSING
   union all
  select type, file_name from CLEANING
)
select *
  from result
 order by type desc;
```



- [ ] prompt query 추가
- [ ] TODO: make clear shell

  ```shell
  # remove trace (ex: < 1M)
  cd /oracle12/app/oracle/diag/rdbms/db1/db1/trace
  
  # alert log
  cd /oracle12/app/oracle/diag/rdbms/db1/db1/trace
  ll alert*
  -rw-r-----. 1 oracle oinstall 1132094 Jul 26 10:27 alert_db1.log
  
  cp alert_db1.log alert_db1.log.20230726; > alert_db1.log
  ll alert*
  -rw-r-----. 1 oracle oinstall       0 Jul 26 10:28 alert_db1.log
  -rw-r-----. 1 oracle oinstall 1132094 Jul 26 10:28 alert_db1.log.20230726
  ```

- [ ] dynamic performance view 중, 특히 v$archived_log와 v$session을 조회하여 특정 테이블로 주기적으로  insert하도록 shell 작성
- [ ] 갭차이 조회 완성(long 타입 대응 함수 얻게되면)
- [ ] 통계 export/import
- [ ] snapshot too old 원인과 해결방법들을 이해하고 정리

