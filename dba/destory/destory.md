# destory

> 오라클 삭제 후, 재설치
>
> **흐름**
>
> 1. deinstall -> common
> 2. manual -> common

## 1. deinstall

> ✅ deinstall을 사용하여 제거를 진행할 경우, 
> oracle과 연관된 모든 디렉토리가 제거되므로
> 별도의 디렉토리나 파일들에 대해 같이 제거되도 괜찮을 경우에만 해당 방법을 이용.

**1. deinstall 실행**

```shell
su - oracle
$ORACLE_HOME/deinstall/deinstall
```

## 2. manual

> 별도의 디렉토리와 파일들이 제거되는 것에 대해 불안하다면
> 직접 수동으로 연관 폴더를 삭제해주도록 하는 것이 보다 안전하지만,
> 무엇이든 지우는 작업에는 항상 경각심을 가지고 진행하도록 한다.
> 가령 지우고 재설치할 경우 직면하게 될 상황을 염두에 두어 진행하도록하자
>
> 1. 프로세스 문제(강제 kill)
>
> 2. Oracle ASM disk
>
>    **scan**: oracleasm scandisk
>    **delete**: oracleasm deletedisk DATA
>    **create**: oracleasm createdisk DATA /dev/sdc1

**서비스 종료 후, 연관 디렉토리&파일 삭제**

```shell
systemctl stop oracle-tfa.service

rm -rf  $ORACLE_HOME
rm -rf  $ORACLE_BASE
rm -rf /etc/oracle
rm -rf /var/tmp/.oracle
rm -rf /var/opt/oracle
rm -rf /opt/ORCLfmap
rm -rf /opt/oracle
rm -rf /opt/oracle.ahf
rm -f /etc/oraInst.loc
rm -f /etc/oratab
rm -f /usr/bin/orachk
rm -f /usr/bin/tfactl
rm -f	/usr/bin/oracle-database-*-preinstall*
rm -f /usr/local/bin/oraenv
```

## 3. common

> deinstall이든, manual로 했든 공통적으로 필요한 작업

**1. 유저&그룹 삭제**

```shell
mkdir -p /opt/reinstall/backup
cp /home/oracle/.bash_profile /opt/reinstall/backup/.bash_profile_oracle
cp /home/oracle/.vimrc /opt/reinstall/backup/.vimrc_oracle
cat /opt/reinstall/backup/.bash_profile_oracle
cat /opt/reinstall/backup/.vimrc_oracle

userdel oracle
groupdel dba
groupdel oinstall
```

**2. 설치계정 디렉토리 삭제**

```shell
rm -rf /home/oracle
```

 **3. 기타 잔여물 삭제**

```shell
rm -rf  $ORACLE_HOME
rm -rf  $ORACLE_BASE
rm -rf /etc/oracle
rm -rf /var/tmp/.oracle
rm -rf /var/opt/oracle
rm -rf /opt/ORCLfmap
rm -rf /opt/oracle 
rm -rf /opt/oracle.ahf
rm -rf /oracle12/*
rm -f /etc/oraInst.loc
rm -f /etc/oratab
rm -f	/usr/bin/oracle-database-*-preinstall*
rm -f /usr/local/bin/oraenv
```

**4. preinstall 삭제**

```shell
yum list installed | grep oracle
yum remove oracle-database-server-12cR2-preinstall.x86_64
```

## 4. reinstall

> **${PROJECT_ROOT}/setting/oracle/2. oracle.md**
>
> You can proceed from **load Oracle Image file**
> ```shell
> scp V839960-01.zip root@172.16.229.132:/oracle12/V839960-01.zip
> ```

**restore profile**

```shell
cp /opt/reinstall/backup/.bash_profile_oracle /home/oracle/.bash_profile
cp /opt/reinstall/backup/.vimrc_oracle /home/oracle/.vimrc
```

