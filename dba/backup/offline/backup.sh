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
  export BACKUPDIR
}

# func: echo directory
func_echo_directory() {
  echo "┌──────────────────────────────────────────────────┐";
  echo "│                 TARGET_DIRECTORY                 │ $BACKUPDIR";
  echo "└──────────────────────────────────────────────────┘";
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

# func: shutdown immediate;
func_shutdown() {
sqlplus -S / as sysdba << _eof_
select instance_name, status from v\$instance;
/
shutdown immediate;
_eof_
}

# func: physical backup
func_backup() {
  cp $(echo "$ORACLE_DATA*") $BACKUPDIR
  cp $(echo "$ORACLE_DBS*") $BACKUPDIR
  cd $BACKUPDIR;ls -al;
}

# func: startup;
func_startup() {
sqlplus -S / as sysdba << _eof_
startup open;
/
select instance_name, status from v\$instance;
_eof_
}

###################################### define function ######################################

###################################### playground ######################################
# START
func_check_constant
func_make_directory $1
func_echo_directory
func_generate_backup_controlfile
func_shutdown
func_backup
func_startup
func_echo_directory
###################################### playground ######################################
exit
