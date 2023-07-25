[toc]

# backup.sh

```shell
#!/bin/sh

#  example
#  case1. just call
#  sh backup.sh 
#  case2. call with parameter another path 
#  sh backup.sh /home/backup
#
#  flow
#  1. make directory and export directory
#  2. generate backup controlfile
#  3. physical copy

clear;

# func: make directory
func_make_directory() {
  if ! [ -z $1 ]
        then
                prefix="$1/"
  fi

  if ! [ -d $prefix ]
        then
                echo "\$prefix is not directory"
                exit 127
  fi

  BACKUPDIR="${prefix}backup_${suffix}"

  mkdir -p $BACKUPDIR
  echo "┌──────────────────────────────────────────────────┐";
  echo "│                 TARGET_DIRECTORY                 │ $BACKUPDIR";
  echo "└──────────────────────────────────────────────────┘";
  export $BACKUPDIR
}

# func: generate backup controlfile
func_generate_backup_controlfile() {
BACKUP_CONTROLFILE="'"$BACKUPDIR/control.sql"'"
if [ -f $BACKUP_CONTROLFILE ]
        then
                rm $BACKUP_CONTROLFILE
fi
sqlplus -S / as sysdba << _eof_
alter database backup controlfile to trace as $BACKUP_CONTROLFILE;
/
_eof_

}

# func: physical backup
func_backup() {
  cp $ORACLE_DATA $BACKUPDIR
  cp $ORACLE_ORA $BACKUPDIR
  cd $BACKUPDIR;ls -al;
}

prefix=/opt/backup4oracle12/
suffix=$(date +"%Y%m%d%H%M")
ORACLE_DATA=/oracle12/app/oracle/oradata/db1/*
ORACLE_ORA=/oracle12/app/oracle/product/12.2.0.1/db_1/dbs/*.ora

# START
func_make_directory $1
func_generate_backup_controlfile
func_backup
```

