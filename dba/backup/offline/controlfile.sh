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
