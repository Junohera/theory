```shell
# ✅ 계정 확인
id
# uid=100(postgres) gid=101(postgres) groups=101(postgres

whoami
# postgres

# ✅ 백업할 대상 디렉토리 이동
cd /tmp

# ✅ pg_basebackup help
pg_basebackup --help

# ✅ pg_basebackup 실행
# DATADIR, checkpoint, progress, vervose
pg_basebackup \
-D backup \
-c fast \
-P \
-v;

# ✅ 백업 이후, 확인
ls
# backup

# ✅ 백업 이후, 확인(backup_label, backup_manifest가 새로이 등장)
cd backup;ls;
PG_VERSION            pg_dynshmem           pg_serial             pg_wal
backup_label	      pg_hba.conf           pg_snapshots          pg_xact
backup_manifest 	  pg_ident.conf         pg_stat               postgresql.auto.conf
base                  pg_logical            pg_stat_tmp           postgresql.conf
global                pg_multixact          pg_subtrans
logfile               pg_notify             pg_tblspc
pg_commit_ts          pg_replslot           pg_twophase

# ✅ 현재 위치에서 백업 검증
pwd
# /tmp/backup
$ pg_verifybackup .
# backup successfully verified

# ✅ 백업으로 새로운 포트로 서비스 시작
# DATADIR, options
pg_ctl -D . -o "-p 5433" start
waiting for server to start....2023-11-21 04:16:23.695 UTC [209] LOG:  starting PostgreSQL 14.5 on i686-buildroot-linux-musl, compiled by i686-buildroot-linux-musl-gcc.br_real (Buildroot 2022.02.8) 11.3.0, 32-bit
2023-11-21 04:16:23.782 UTC [209] LOG:  listening on IPv4 address "127.0.0.1", port 5433
2023-11-21 04:16:23.783 UTC [209] LOG:  listening on Unix socket "/tmp/.s.PGSQL.5433"
2023-11-21 04:16:23.912 UTC [210] LOG:  database system was interrupted; last known up at 2023-11-21 04:10:59 UTC
2023-11-21 04:16:24.179 UTC [210] LOG:  redo starts at 0/2000024
2023-11-21 04:16:24.180 UTC [210] LOG:  consistent recovery state reached at 0/20000E4
2023-11-21 04:16:24.181 UTC [210] LOG:  redo done at 0/20000E4 system usage: CPU: user: 0.00 s, system: 0.00 s, elapsed: 0.00 s
2023-11-21 04:16:24.426 UTC [209] LOG:  ✨database system is ready to accept connections✨
 done
server started

# ✅ 확인
psql -p 5433
psql (14.5)
Type "help" for help.

postgres=#

# ✅ backup 파일 변경 확인
postgres=# \q

# ✅ .old 확인(용에는 START 정보만 있어야한다. STOP 관련 정보가 있다면, 잘못된 베이스 백업 자료)
# start하고나면, backup_label -> backup_label.old로 변경
cat backup_label.old
START WAL LOCATION: 0/2000024 (file 000000010000000000000002)
CHECKPOINT LOCATION: 0/2000058
BACKUP METHOD: streamed
BACKUP FROM: primary
START TIME: 2023-11-21 04:10:59 UTC
LABEL: pg_basebackup base backup
START TIMELINE: 1
```

