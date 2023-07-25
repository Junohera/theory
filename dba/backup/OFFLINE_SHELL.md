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

###################################### define constant ######################################
prefix=/opt/backup4oracle12/
suffix=$(date +"%Y%m%d%H%M")
ORACLE_DATA=/oracle12/app/oracle/oradata/db1/
ORACLE_DBS=/oracle12/app/oracle/product/12.2.0.1/db_1/dbs/
###################################### define constant ######################################

###################################### define function ######################################
# func: check constant
func_check_constant() {
	ls $ORACLE_DATA | grep ".dbf" > /dev/null
	IS_EXIST_DBF=$(echo $?)
	ls $ORACLE_DATA | grep ".ctl" > /dev/null
	IS_EXIST_CTL=$(echo $?)
	ls $ORACLE_DATA | grep ".log" > /dev/null
	IS_EXIST_LOG=$(echo $?)
	ls $ORACLE_DBS | grep ".ora" > /dev/null
	IS_EXIST_ORA=$(echo $?)
	
	if [ $IS_EXIST_DBF -ne 0 ]; then echo "NOT EXISTS ($ORACLE_DATA*.dbf)"; exit 127; fi
	if [ $IS_EXIST_CTL -ne 0 ]; then echo "NOT EXISTS ($ORACLE_DATA*.ctl)"; exit 127; fi
	if [ $IS_EXIST_LOG -ne 0 ]; then echo "NOT EXISTS ($ORACLE_DATA*.log)"; exit 127; fi
	if [ $IS_EXIST_ORA -ne 0 ]; then echo "NOT EXISTS ($ORACLE_DBS*.ora)"; exit 127; fi
}

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
  export BACKUPDIR
}

# func: generate backup controlfile
func_generate_backup_controlfile() {
BACKUP_CONTROLFILE="$BACKUPDIR/control.sql"
BACKUP_CONTROLFILE_FOR_QUERY="'"$BACKUPDIR/control.sql"'"
if [ -f $BACKUP_CONTROLFILE ]
        then
                rm $BACKUP_CONTROLFILE
fi
sqlplus -S / as sysdba << _eof_
select instance_name, status from v\$instance;
/
alter database backup controlfile to trace as $BACKUP_CONTROLFILE_FOR_QUERY;
_eof_
}

# func: physical backup
func_backup() {
  cp $(echo "$ORACLE_DATA*") $BACKUPDIR
  cp $(echo "$ORACLE_DBS*") $BACKUPDIR
  cd $BACKUPDIR;ls -al;
}
###################################### define function ######################################

###################################### playground ######################################
# START
func_check_constant
func_make_directory $1
func_generate_backup_controlfile
func_backup
###################################### playground ######################################
exit
```

# restore.sh

```shell
#!/bin/sh

clear;
###################################### define constant ######################################
FIND_DIR=/opt/
ORACLE_DATA=/oracle12/app/oracle/oradata/db1/
ORACLE_DBS=/oracle12/app/oracle/product/12.2.0.1/db_1/dbs/
###################################### define constant ######################################

###################################### define function ######################################
# func: find directory, check constant, exist physical files
func_initialize() {
  cd /;find $FIND_DIR -mindepth 1 -maxdepth 3 -type d | grep "backup*" | cat -n;
  echo "Enter backup directory full path(doublc click and right click): \c";
  read BACKUPDIR;

  echo "┌──────────────────────────────────────────────────┐";
  echo "│                 TARGET_DIRECTORY                 │ $BACKUPDIR";
  echo "└──────────────────────────────────────────────────┘";
  if ! [ -d $BACKUPDIR ]; then echo "\$BACKUPDIR is not directory."; exit 127; fi
  if ! [ -d $ORACLE_DATA ]; then echo "\$ORACLE_DATA is not directory."; exit 127; fi
  if ! [ -d $ORACLE_DBS ]; then echo "\$ORACLE_DBS is not directory."; exit 127; fi
  
  ls $ORACLE_DATA | grep ".dbf" > /dev/null
	IS_EXIST_DBF=$(echo $?)
  ls $ORACLE_DATA | grep ".ctl" > /dev/null
	IS_EXIST_CTL=$(echo $?)
  ls $ORACLE_DATA | grep ".log" > /dev/null
	IS_EXIST_LOG=$(echo $?)
  ls $ORACLE_DBS | grep ".ora" > /dev/null
	IS_EXIST_ORA=$(echo $?)
	
	if [ $IS_EXIST_DBF -ne 0 ]; then echo "NOT EXISTS ($ORACLE_DATA*.dbf)"; exit 127; fi
	if [ $IS_EXIST_CTL -ne 0 ]; then echo "NOT EXISTS ($ORACLE_DATA*.ctl)"; exit 127; fi
	if [ $IS_EXIST_LOG -ne 0 ]; then echo "NOT EXISTS ($ORACLE_DATA*.log)"; exit 127; fi
	if [ $IS_EXIST_ORA -ne 0 ]; then echo "NOT EXISTS ($ORACLE_DBS*.ora)"; exit 127; fi
  
  export BACKUPDIR
}

# func: physical backup
func_restore() {
  rm $(echo "$ORACLE_DATA*")
  rm $(echo "$ORACLE_DBS*")

  cd $ORACLE_DATA
  cp $BACKUPDIR/* ./
  rm *.ora

  cd $ORACLE_DBS
  cp $BACKUPDIR/*.ora ./
}

# func: shutdown immediate
func_shutdown() {
sqlplus -S / as sysdba << _eof_
select status from v\$instance
/
shutdown immediate
_eof_
}

# func: startup open
func_startup() {
sqlplus -S / as sysdba << _eof_
startup
select status from v\$instance
/
_eof_
}
###################################### define function ######################################

###################################### playground ######################################
func_initialize
func_shutdown
func_restore
func_startup
###################################### playground ######################################
exit
```

# controlfile.sh

```shell
#!/bin/sh

clear;
###################################### define function ######################################
# func: backup controlfile
func_backup_controlfile() {
BACKUPDIR=/opt/backup4oracle12
BACKUP_CONTROLFILE="$BACKUPDIR/control.sql"
BACKUP_CONTROLFILE_FOR_QUERY="'"$BACKUPDIR/control.sql"'"
if [ -f $BACKUP_CONTROLFILE ]
        then
                rm $BACKUP_CONTROLFILE
fi
sqlplus -S / as sysdba << _eof_
select instance_name, status from v\$instance;
/
alter database backup controlfile to trace as $BACKUP_CONTROLFILE_FOR_QUERY;
_eof_
}
###################################### define function ######################################

func_backup_controlfile
```

