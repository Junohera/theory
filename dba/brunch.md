[toc]

# 0. Summary

```shell
sqlplus / as sysdba # SQL> startup
lsnrctl status
lsnrctl start
lsnrctl status
ps -ef | grep lsnr | grep -v grep # pslsnr
ps -ef | grep pmon | grep -v grep # pspmon
```

---

# 1. Run OEL7 [^OEL]

# 2. Check ip

## 📐 if before != current

### server

- [ ] hosts 확인
  ```shell
  cat /etc/hosts
  
  ...
  172.16.192.129 oel7
  ```

### client

- [ ] tnsnames.ora 확인
  ```shell
  # bash shell in window 
  echo $PATH
  ??? # TODO: GET associated oracle paths
  ```


# 3. Open DB

```shell
sqlplus / as sysdba
SQL> startup
```

# 4. Start Listener

```shell
lsnrctl start
lsnrctl status
```

# 5. Check process

```shell
ps -ef | grep lsnr | grep -v grep
ps -ef | grep pmon | grep -v grep
```

---

[^OEL]: Oracle Enterprise Linux

