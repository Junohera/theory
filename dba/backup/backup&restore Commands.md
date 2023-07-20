[toc]

# backup&restore Commands

## flow

### backup

```shell
SQL> shutdown immediate;

backupdir=/opt/backup4oracle12/backup_$(date +"%Y%m%d%H%M")
echo $backupdir

mkdir -p $backupdir
cp /oracle12/app/oracle/oradata/db1/* $backupdir
cp /oracle12/app/oracle/product/12.2.0.1/db_1/dbs/*.ora $backupdir

cd $backupdir;ll;
total 2751240
-rw-r-----. 1 oracle oinstall  10600448 Jul 20 11:46 control01.ctl
-rw-r-----. 1 oracle oinstall  10600448 Jul 20 11:46 control02.ctl
-rw-r--r--. 1 oracle oinstall      1010 Jul 20 11:46 initdb1.ora
-rw-r--r--. 1 oracle oinstall      3079 Jul 20 11:46 init.ora
-rw-r-----. 1 oracle oinstall 209715712 Jul 20 11:46 redo01.log
-rw-r-----. 1 oracle oinstall 209715712 Jul 20 11:46 redo02.log
-rw-r-----. 1 oracle oinstall 209715712 Jul 20 11:46 redo03.log
-rw-r-----. 1 oracle oinstall      3584 Jul 20 11:46 spfiledb1.ora
-rw-r-----. 1 oracle oinstall 576724992 Jul 20 11:46 sysaux01.dbf
-rw-r-----. 1 oracle oinstall 734011392 Jul 20 11:46 system01.dbf
-rw-r-----. 1 oracle oinstall  20979712 Jul 20 11:46 temp01.dbf
-rw-r-----. 1 oracle oinstall 351281152 Jul 20 11:46 undotbs01.dbf
-rw-r-----. 1 oracle oinstall   5251072 Jul 20 11:46 users01.dbf

df
```

### restore

```shell
SQL> shutdown immediate;

cd /;find /opt/backup4oracle12/ -mindepth 1 -maxdepth 1 -type d | grep "backup*";

rm /oracle12/app/oracle/oradata/db1/*
rm /oracle12/app/oracle/product/12.2.0.1/db_1/dbs/*

backupdir=/opt/backup4oracle12/backup_202307201109
echo $backupdir

cp $backupdir/* /oracle12/app/oracle/oradata/db1
rm /oracle12/app/oracle/oradata/db1/*.ora

cp $backupdir/*.ora /oracle12/app/oracle/product/12.2.0.1/db_1/dbs

```

### archive mode

#### archive log mode 전환

```sql
startup mount;
alter database archivelog;
alter database open;
```

#### archive 위치 변경 후 DB 재기동

```sql
!mkdir -p /home/oracle/arch
alter system set log_archive_dest_1='location=/home/oracle/arch' scope=spfile;

shutdown immediate;
startup;
```

#### archive 상태 확인

```sql
SQL> archive log list

Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            /home/oracle/arch
...
```

### datafile 구성 확인

```sql
select * from v$controlfile;
select * from v$logfile;
select * from v$datafile;
select * from dba_data_files;
select * from dba_tablespaces;
```

### ~~trace reset~~

> 현업에서는 수행하지 말것.
>
> 제한된 용량만 할당받은 환경속에서 꾸역꾸역 테스트를 진행하기 위한 행위임.(일반적으로 로컬)

#### 1. trace 위치로 이동

```shell
cd /oracle12/app/oracle/diag/rdbms/db1/db1/trace
```

#### 2. trace위치 안에서 정리

```shell
# 1. cdmp 폴더 삭제
find . -mindepth 1 -maxdepth 1 -type d -name "cdmp*"
rm -r cdmp*

# 2. trace 파일 삭제
find . -mindepth 1 -maxdepth 1 -type f -name "*tr*"
rm *tr*

# 3. 로그 초기화
> alert_db1.log
```

> 정리전
>
> ```shell
> Filesystem              1K-blocks     Used Available Use% Mounted on
> devtmpfs                  1988764        0   1988764   0% /dev
> tmpfs                     2008144   983040   1025104  49% /dev/shm
> tmpfs                     2008144     9684   1998460   1% /run
> tmpfs                     2008144        0   2008144   0% /sys/fs/cgroup
> /dev/mapper/ol-root      58216680 18471348  39745332  32% /
> /dev/mapper/ol-home      19523584   194456  19329128   1% /home
> /dev/mapper/ol-oracle12  39044480  9958448  29086032  26% /oracle12
> /dev/sda1                  972460   308256    664204  32% /boot
> tmpfs                      401632       12    401620   1% /run/user/42
> tmpfs                      401632        0    401632   0% /run/user/54321
> ```
>
> 정리후
>
> ```shell
> Filesystem              1K-blocks     Used Available Use% Mounted on
> devtmpfs                  1988764        0   1988764   0% /dev
> tmpfs                     2008144   983040   1025104  49% /dev/shm
> tmpfs                     2008144     9684   1998460   1% /run
> tmpfs                     2008144        0   2008144   0% /sys/fs/cgroup
> /dev/mapper/ol-root      58216680 18471084  39745596  32% /
> /dev/mapper/ol-home      19523584   194456  19329128   1% /home
> /dev/mapper/ol-oracle12  39044480  9940148  29104332  26% /oracle12
> /dev/sda1                  972460   308256    664204  32% /boot
> tmpfs                      401632       12    401620   1% /run/user/42
> tmpfs                      401632        0    401632   0% /run/user/54321
> ```
