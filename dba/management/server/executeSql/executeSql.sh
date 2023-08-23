#!/bin/sh

# sample
# sh execute_sql.sh 'select 1 from dual;' 'test'

logging="$0.log"
queryname="$2"
#################### DEFINITION ####################
LOG() {
  if ! [ -f $logging ]; then
    > $logging
  fi
  echo "$1" >> $logging
}

LOG_START() {
  export tag=$(echo $(date +%N%SS%M%H%d%m%Y))
  export operation_time_start=$(echo $(date +%S))

  LOG ""
  LOG "======= TRY CONNECTION AT: $(date +%FT) ========"
  LOG "$queryname"
  LOG "-------------------- INFO ---------------------"
  LOG "    TAG= $tag"
  LOG "    username= $username"
  LOG "    pagesize= $pagesize"
  LOG "    linesize= $linesize"
  LOG "-------------------- QUERY --------------------"
  LOG "$query"
}

LOG_END() {
  operation_time_end=$(echo $(date +%S))
  operation_time=$(($operation_time_end - $operation_time_start))

  LOG "-------------------- RESULT -------------------"
  LOG "$result"
  LOG "-------------------- DONE ---------------------"
  LOG "    TAG= $tag"
  LOG "operation time: $operation_time"
  LOG "======= SUCCESS AT: $(date +%FT) ==============="
}
#################### INITIALIZE ####################
username="scott"
password="oracle"
pagesize=0
linesize=1000

query="$(echo "$1" | sed '/^$/d')"
#################### PLAYGROUND ####################
LOG_START
result=$(sqlplus -S ${username}/${password} <<EOF
set head off
set feedback off
set pagesize ${pagesize}
set linesize ${linesize}
${query}
exit;
EOF
)
LOG_END

echo "$result"
