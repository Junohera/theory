# Offline Full Backup

> DB가 중지된 상태에서 DB운영에 필요한 모든 파일을 백업, 단, 데이터 유실

## Target files

1. data file
2. redolog file
3. control file
4. parameter file

## Flow

- [ ] **1. control file 위치 확인**

```sql
SQL> col name format a30;
SQL> select * from v$controlfile;

STATUS  NAME                           IS_ BLOCK_SIZE FILE_SIZE_BLKS     CON_ID
------- ------------------------------ --- ---------- -------------- ----------
        /oracle12/app/oracle/oradata/d NO       16384            646          0
        b1/control01.ctl

        /oracle12/app/oracle/oradata/d NO       16384            646          0
        b1/control02.ctl
```

- [ ] **2. shutdown**

```sql
SQL> shutdown immediate;
SQL> select instance_name, status from v$instance;
```

- [ ] **3. 백업 폴더 확인 및 생성**

```shell
mkdir /oracle12/backup
```

- [ ] **4. control files 확인**

```shell
cd /oracle12/app/oracle/oradata/db1/;ll;
```

- [ ] **5. control files 복사**

```shell
cp /oracle12/app/oracle/oradata/db1/* /oracle12/backup
```

- [ ] **5. parameter file 복사**

```shell
cp ${ORACLE_HOME}/dbs/*.ora /oracle12/backup
```

- [ ] **6. backup 파일 확인**

```shell
cd /oracle12/backup;ll;
total 2265680
-rw-r-----. 1 oracle oinstall  10600448 Jul 11 10:02 control01.ctl
-rw-r-----. 1 oracle oinstall  10600448 Jul 11 10:02 control02.ctl
-rw-r--r--. 1 oracle oinstall       952 Jul 11 10:03 initdb1.ora
-rw-r--r--. 1 oracle oinstall      3079 Jul 11 10:03 init.ora
-rw-r-----. 1 oracle oinstall 209715712 Jul 11 10:02 redo01.log
-rw-r-----. 1 oracle oinstall 209715712 Jul 11 10:02 redo02.log
-rw-r-----. 1 oracle oinstall 209715712 Jul 11 10:02 redo03.log
-rw-r-----. 1 oracle oinstall      2560 Jul 11 10:03 spfiledb1.ora
-rw-r-----. 1 oracle oinstall 576724992 Jul 11 10:02 sysaux01.dbf
-rw-r-----. 1 oracle oinstall 734011392 Jul 11 10:03 system01.dbf
-rw-r-----. 1 oracle oinstall  20979712 Jul 11 10:03 temp01.dbf
-rw-r-----. 1 oracle oinstall 351281152 Jul 11 10:03 undotbs01.dbf
-rw-r-----. 1 oracle oinstall   5251072 Jul 11 10:03 users01.dbf
```

