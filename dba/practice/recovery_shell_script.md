```shell
#!/bin/sh

# offline full backup본 으로부터 backup본 시점으로
# 복구를 진행하는 스크립트

# env
backdir=/oracle12/backup

f_db_startup() {
sqlplus -S / as sysdba << _eof_
startup
select status from v\$instance
/
_eof_
}

f_db_shutdown() {
sqlplus -S / as sysdba << _eof_
select status from v\$instance
/
shutdown immediate
_eof_
}


# main
# 1. offline backup본 확인
cd $backdir
ls | grep ".dbf" > /dev/null
true1=$(echo $?)
ls | grep ".ctl" > /dev/null
true2=$(echo $?)
ls | grep ".log" > /dev/null
true3=$(echo $?)
ls | grep spfile*ora > /dev/null
true4=$(echo $?)

if [ $true1 -eq 0 ] && [ $true2 -eq 0 ] && [ $true3 -eq 0 ] && [ $true4 -eq 0 ]
then
  echo "backup본 존재"
  echo "full restore & recovery를 진행합니다"
else
  echo "backup본이 없습니다"
  echo "recovery를 중단합니다"
  exit 1
fi

# 2. db startup 상태 확인 
ps -ef | grep pmon | grep -v grep > /dev/null
if [ $? -eq 0 ]
then
  echo "DB가 open되어 있습니다"
  echo "DB를 shutdown 하겠습니다"
  f_db_shutdown
else
  echo "DB가 shutdown되어 있습니다"
fi
  
# 3. restore & recovery 진행
echo "restore를 진행하겠습니다"
cplist=$(ls /oracle12/backup | grep -v ora)
cd /oracle12/backup
cp $cplist /oracle12/app/oracle/oradata/db1
cp *.ora /oracle12/app/oracle/product/12.2.0.1/db_1/dbs
echo "resotre를 완료하였습니다"

# 4. DB starup
echo "DB를 startup 하겠습니다"
f_db_startup
echo "DB가 정상으로 open되었습니다"
echo "restore & recovery 작업을 종료합니다"
```

