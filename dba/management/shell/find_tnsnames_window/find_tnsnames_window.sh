#!/bin/bash

# 목적
# CLIENT의 TNSNMES.ORA파일을 확인하기 위한 SHELL
#
# 내용
# 1. tnsnames.ora 파일 탐색
#   1.1. 환경변수에서 가장 우선순위 높은 경로 유추(/app/product)
#   1.2. 1.1번이 없을 경우, 뒤져서 검색(sample/tnsnames.ora)
# 2. tnsnames.ora 안에서 sid 선택
# 3. 폴더 및 파일 열기

clear

function open() {
  echo "$1"
  cd "$1" || exit
  cat -n tnsnames.ora
  echo
  echo "┌────────────────────────────────────────┐"
  echo "│   위의 본문에서 대상 SID를 입력하세요. │"
  echo "└────────────────────────────────────────┘"
  read sid
  clear
  echo "PATH: $(pwd)/tnsnames.ora"
  from=$(
    cat -n tnsnames.ora | grep -w "${sid} =" | awk -F " " '{print $1}'
  )
  to=$(expr "$from" + 7)
  echo "FROM: ${from}, TO: ${to}"
  cat -n tnsnames.ora | sed -n "${from},${to}p"
  echo
  echo "do you wanna open ? (just open)"
  read ans
  if [[ $ans = 'y' ]] ||  [[ $ans = 'Y' ]]; then
    explorer .
    explorer tnsnames.ora
  fi
  
  exit
}

# 1. tnsnames.ora 파일 탐색
predictedByPathByEnvironmentVariablePriority=$(echo "$PATH" | sed 's/:/\n/g' | grep app | grep product | head -1 | sed 's/\/bin//' | awk '{print $1"/network/admin/"}')
ls "$predictedByPathByEnvironmentVariablePriority" 2>/dev/null

if [ $? -eq 0 ]; then
  TARGET_PATH=$predictedByPathByEnvironmentVariablePriority
else
  for p in $(find /c/app -type f -name "tnsnames.ora" | grep "sample")
  do
    TARGET_PATH=$(echo $p | grep /network/admin | awk -F "/sample/" '{print $1}')
    ls $TARGET_PATH > /dev/null
    if [ $? -eq 0 ]; then
      echo "$TARGET_PATH"
      echo "break"
      break
    fi
  done  

fi

ls $TARGET_PATH > /dev/null
if [ $? -eq 2 ]; then
  echo "First, Install the admin client(TNSNAMES.ORA IS NOT EXISTS)"
  exit
fi

open "$TARGET_PATH"