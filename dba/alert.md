**alert log**

```shell
cd $ORACLE_HOME
find . -type d -name trace
# /oracle12/app/oracle/product/12.2.0.1/db_1/network/trace
tail -f /oracle12/app/oracle/product/12.2.0.1/db_1/network/trace/alert_db1.log
```

