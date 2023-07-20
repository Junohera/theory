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
Oldest online log sequence     7
Next log sequence to archive   9
Current log sequence           9
```

### datafile 구성 확인

```sql
select * from v$controlfile;
select * from v$logfile;
select * from v$datafile;
select * from dba_data_files;
select * from dba_tablespaces;
```



