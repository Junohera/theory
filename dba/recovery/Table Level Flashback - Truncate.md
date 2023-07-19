[toc]

# Table Level Flashback - Truncate

- trancate table은 auto commit 이므로 즉시 반영
- redo에 기록하지 않음(해당 scn 정보가 redo에 없음)
- 이럴 때, trancate 이전 시점으로 시점복구 진행 필요
  - redo의 해당 시점 이후 데이터 reset 필요(resetlogs)
  - DB online 중 복구 불가(mount에서 진행)

## 관리

### 1. 테이블 확인

```sql
select * from flashback_test;
```

### 2. select systimestamp from dual;

```sql
select systimestamp from dual; -- 2023-07-19 15:12:34.183 +0900
```

### 3. truncate table flashback_test;

```sql
truncate table flashback_test;
select * from flashback_test;
```

### 4.복구시도

```sql
SQL> shutdown immediate
SQL> startup mount

SQL> flashback database to timestamp(to_timestamp('2023-07-19 15:12:34', 'YYYY-MM-DD HH24:MI:SS'));
Flashback complete.

SQL> alter database open;
alter database open
*
ERROR at line 1:
ORA-01589: must use RESETLOGS or NORESETLOGS option for database open

SQL> alter database open resetlogs;
Database altered.

SQL> select * from flashback_test;
```

resetlogs: redo log를 날리고 복구(datafile을 기준으로)
예시: 특정 시점의 데이터 상황을 완벽 신뢰하는 경우 redolog를 포기해도 되는 상황

noresetlogs: redo log를 유지하고 복구
예시: redolog를 포기할 수 없는 상황 ??



