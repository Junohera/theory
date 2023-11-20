[toc]

# Clone

## require list

**1. logswitch**

current로 바라보던 redologfile에 남아있는 기록들도 archive로 남기기 위함.

**2. parameter file**

만약 spfile이라면 pfile생성할 것

**3. datafile**

**4. archive log file**

**5. backup controlfile**

---

## flow

### 1. OS 환경변수 확인

```shell
echo $PATH
echo $ORACLE_HOME
echo $ORACLE_SID

$ORACLE_HOME/dbs/init${ORACLE_SID}.ora
cd $ORACLE_HOME/bin/
```

**$ORACLE_HOME**
설치시 정해진 곳이므로 변경 불가
$ORACLE_HOME/dbs 디렉토리에 파라미터 파일 restore

**$PATH**
시스템 환경변수로 $ORACLE_HOME 디렉토리가 등록되어 있는지 확인하고, 등록되어 있지 않을 경우, SQLPLUS, LSNRCTL 등의 명령어 실행불가

**$ORACLE_SID**
oracle db name을 의미하는 os 환경변수로 해당 이름의 db로 기동되므로 recovery시 반드시 변경 필요

### 2. restore

1. online/offline backup file
   archive가 정상적으로 기록되고 있는 가장 마지막 시점의 backup file 중 datafile들만 restore

   ✅controlfile은 재생성 스크립트로 재생성가능
   ✅redo는 online중 copy가 불가하므로, log switch를 통해 아카이브로 내려쓴 뒤 아카이브를 restore하는 방향 => 결과적으로 redo를 백업(=from current to inactive)

2. parameter file
   parameter file을 수정할 확률이 높기 때문에 init${SID}.ora 파일을 restore

3. archive log file
   마지막 backup 시점을 포함하여 복구 시점까지의 아카이브 restore

4. backup controlfile

### 3. recovery

