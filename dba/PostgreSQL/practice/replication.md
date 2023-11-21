```shell
# ✅ 기동서버 경로이동(basebackup.md에 이어서 했기 때문에 경로는 다음과 같다.)
cd /tmp/backup
ls

# ✅ 종료
pg_ctl -D . stop

# ✅ 프로세스 확인
ps x

# ✅ 상위 경로 이동 및 삭제
cd ../;rm -rf backup/;

# ✅ 삭제 확인
ls

# ✅ readonly로 백업(-R)
pg_basebackup -D backup -c fast -P -v -C -S slot1 -R

# ✅ 백업 및 파일 확인
cd backup/
ls
PG_VERSION            pg_dynshmem           pg_serial             pg_wal
backup_label          pg_hba.conf           pg_snapshots          pg_xact
backup_manifest       pg_ident.conf         pg_stat               postgresql.auto.conf
base                  pg_logical            pg_stat_tmp           postgresql.conf
global                pg_multixact          pg_subtrans           standby.signal✅
logfile               pg_notify             pg_tblspc
pg_commit_ts          pg_replslot           pg_twophase

# ✅ 설정파일 확인
cat postgresql.auto.conf
vi postgresql.auto.conf
primary_conninfo = 'user=postgres passfile=''/var/lib/pgsql/.pgpass'' channel_binding=disable✅
primary_slot_name = 'slot1'✅

# ✅ 실행
pg_ctl -D . -o "-p 5433" start
waiting for server to start....2023-11-21 05:15:21.218 UTC [292] LOG:  starting PostgreSQL 14.5 on i686-buildroot-linux-musl, compiled by i686-buildroot-linux-musl-gcc.br_real (Buildroot 2022.02.8) 11.3.0, 32-bit
2023-11-21 05:15:21.221 UTC [292] LOG:  listening on IPv4 address "127.0.0.1", port 5433
2023-11-21 05:15:21.221 UTC [292] LOG:  listening on Unix socket "/tmp/.s.PGSQL.5433"
2023-11-21 05:15:21.474 UTC [293] LOG:  database system was interrupted; last known up at 2023-11-21 05:10:23 UTC
2023-11-21 05:15:21.684 UTC [293] LOG:  entering standby mode✅
2023-11-21 05:15:21.785 UTC [293] LOG:  redo starts at 0/4000024
2023-11-21 05:15:21.785 UTC [293] LOG:  consistent recovery state reached at 0/4000118
2023-11-21 05:15:21.887 UTC [292] LOG:  database system is ready to accept read-only connections✅
 done
server started
$ 2023-11-21 05:15:22.152 UTC [297] LOG:  started streaming WAL from primary at 0/5000000 on timeline 1

# ✅ 접속
psql -p 5433

# ✅ DDL 시도
create table test(a int);💥
2023-11-21 05:16:03.210 UTC [300] ERROR:  cannot execute CREATE TABLE in a read-only transaction
2023-11-21 05:16:03.210 UTC [300] STATEMENT:  create table test(a int);
ERROR:  cannot execute CREATE TABLE in a read-only transaction

✅ 모니터링 대상 값 조회(pg_stat_replication, pg_replication_slots)
psql
select * from pg_stat_replication \gx
-[ RECORD 1 ]----+----------------------------
pid              | 298
usesysid         | 10
usename          | postgres
application_name | walreceiver
client_addr      | 
client_hostname  | 
client_port      | -1
backend_start    | 2023-11-21 05:15:22.1384+00
backend_xmin     | 
state            | streaming 💎
sent_lsn         | 0/5000128
write_lsn        | 0/5000128
flush_lsn        | 0/5000128
replay_lsn       | 0/5000128
write_lag        | 💎
flush_lag        | 💎
replay_lag       | 💎
sync_priority    | 0
sync_state       | async
reply_time       | 2023-11-21 05:19:31.2749+00
select * from pg_replication_slots \gx
-[ RECORD 1 ]-------+----------
slot_name           | slot1
plugin              | 
slot_type           | physical
datoid              | 
database            | 
temporary           | f
active              | t 💎
active_pid          | 298
xmin                | 
catalog_xmin        | 
restart_lsn         | 0/5000128 💎
confirmed_flush_lsn | 
wal_status          | reserved 💎
safe_wal_size       | 
two_phase           | f
```

- 더 이상 해당 보조 서버를 사용하지 않는다면, 그 보조 서버가 사용했던 복제 슬롯을 주 서버에서 지워야함을 잊지 말아야한다. 

```sql
select pg_drop_replication_slot('${SLOT_NAME}');
```