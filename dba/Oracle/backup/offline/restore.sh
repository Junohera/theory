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
  
  #   ls $ORACLE_DATA | grep ".dbf" > /dev/null
  # 	IS_EXIST_DBF=$(echo $?)
  #   ls $ORACLE_DATA | grep ".ctl" > /dev/null
  # 	IS_EXIST_CTL=$(echo $?)
  #   ls $ORACLE_DATA | grep ".log" > /dev/null
  # 	IS_EXIST_LOG=$(echo $?)
  #   ls $ORACLE_DBS | grep ".ora" > /dev/null
  # 	IS_EXIST_ORA=$(echo $?)
  #
  # 	if [ $IS_EXIST_DBF -ne 0 ]; then echo "NOT EXISTS ($ORACLE_DATA*.dbf)"; exit 127; fi
  # 	if [ $IS_EXIST_CTL -ne 0 ]; then echo "NOT EXISTS ($ORACLE_DATA*.ctl)"; exit 127; fi
  # 	if [ $IS_EXIST_LOG -ne 0 ]; then echo "NOT EXISTS ($ORACLE_DATA*.log)"; exit 127; fi
  # 	if [ $IS_EXIST_ORA -ne 0 ]; then echo "NOT EXISTS ($ORACLE_DBS*.ora)"; exit 127; fi
  
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
