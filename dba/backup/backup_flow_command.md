# backup 절차별 커맨드

## flow



oradata

```shell
shutdown immediate;
mkdir -p /oracle12/backup
cd /oracle12/app/oracle/oradata/db1
cp /oracle12/app/oracle/oradata/db1/* /oracle12/backup
startup

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

