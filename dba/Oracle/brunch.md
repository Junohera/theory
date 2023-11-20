[toc]

# 0. Summary

```shell
# SERVER
ps -ef | grep pmon | grep -v grep
ps -ef | grep lsnr | grep -v grep

lsnrctl status

sqlplus / as sysdba # SQL> startup
lsnrctl start
lsnrctl status

ps -ef | grep lsnr | grep -v grep # pslsnr
ps -ef | grep pmon | grep -v grep # pspmon

# CLIENT
select instance_name, status from v$instance;
```

---

# 1. Run OEL7 [^OEL]

# 2. Check ip

### server

- [x] hosts 확인
  
  - [x] **A**: get Physical_Host_Address by Logical Target Host
  
    ```shell
    cat /etc/hosts
    
    ...
    172.16.192.129 oel7
    ```
  
    ```shell
    cat /etc/hosts | sed '/${LOGICAL_TARGET_HOST}/!d' | cut -d" " -f1
    cat /etc/hosts | sed '/oel7/!d' | cut -d" " -f1
    
    # result
    [oracle@oel7 ~]$ cat /etc/hosts | sed '/oel7/!d' | cut -d" " -f1
    172.16.192.129
    ```
  
  - [x] **B**: get Physical_Host_Address in target server
  
    ```shell
    ifconfig
    ```
  
    ```shell
    ifconfig\
    | head -2 \
    | tail -1 \
    | awk -Fnetmask '{print $1}' \
    | awk -F" " '{print $NF}';
    
    # result
    [oracle@oel7 ~]$ ifconfig\
    > | head -2 \
    > | tail -1 \
    > | awk -Fnetmask '{print $1}' \
    > | awk -F" " '{print $NF}';
    172.16.192.129
    ```
  
  - [x] comp (**A**, **B**)
  
    **📐 if before != current**
  
    ```shell
    vi /etc/hosts
    
    ...
    172.16.192.129 oel7 # ${B} ${LOGICAL_TARGET_HOST}
    ```

### client

- [x] tnsnames.ora 확인
  ✔**open every tnsnames.ora in window**
  
  ```shell
  clear;num=0;for tnsoranames_path in $(echo $PATH| sed 's/:/\n/g'| grep app| grep product| sed 's/\/bin//'| awk '{print $1"/NETWORK/ADMIN"}'); do if [ -d $tnsoranames_path ]; then num=$(expr $num + 1);echo '---------------------------------------------------------------------------------------------------------------------------------------------------------';echo "no: $num";echo "path: $tnsoranames_path";cd $tnsoranames_path;cat -n tnsnames.ora;echo; fi done;
  ```
  
  ✔**open tnsnames.ora directory at top priority in oracle environment path**
  
  ```shell
  clear;cd $(echo $PATH| sed 's/:/\n/g'| grep app| grep product| head -1| sed 's/\/bin//'| awk '{print $1"/NETWORK/ADMIN"}');cat -n tnsnames.ora;echo ;echo "┌────────────────────────────────────────┐";echo "│   위의 본문에서 대상 SID를 입력하세요. │";echo "└────────────────────────────────────────┘";read sid;clear;echo "PATH: $(pwd)/tnsnames.ora";from=$(cat -n tnsnames.ora| grep -w "${sid} ="| awk -F" " '{print $1}');to=$(expr $from + 7);echo "FROM: ${from}, TO: ${to}";cat -n tnsnames.ora| sed -n "${from},${to}p";echo; echo "do you wanna open ? (just open)";read ans;explorer .; explorer tnsnames.ora;exit;
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

 
