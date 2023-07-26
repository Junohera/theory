[toc]

# Clear

## Storage

TODO: make clear shell

```shell
# remove trace (ex: < 1M)
cd /oracle12/app/oracle/diag/rdbms/db1/db1/trace

# alert log
cd /oracle12/app/oracle/diag/rdbms/db1/db1/trace
ll alert*
-rw-r-----. 1 oracle oinstall 1132094 Jul 26 10:27 alert_db1.log

cp alert_db1.log alert_db1.log.20230726; > alert_db1.log
ll alert*
-rw-r-----. 1 oracle oinstall       0 Jul 26 10:28 alert_db1.log
-rw-r-----. 1 oracle oinstall 1132094 Jul 26 10:28 alert_db1.log.20230726
```

