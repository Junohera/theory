최소 하나 이상의 모니터링 툴과 친숙해져야한다.

최소 시각화된 정보들을 읽을 수 있어야하고
각 지표의 의미와 엔진과의 연관관계를 알아야 한다.

모니터링을 하기위한 지표들을 확인하는데에
쉘 명령어로 50%정도 감당이 가능하다.(os 의존도 큼)



### top

```shell
top -c -d 1 -U postgres
||
top -c -d 1
```

```shell
top - 15:11:20 up 3 min,  1 user,  1️⃣load average: 0.14, 0.10, 0.04
2️⃣Tasks:  36 total,   1 running,  35 sleeping,   0 stopped,   0 zombie
3️⃣%Cpu(s):  0.1 us,  0.1 sy,  0.0 ni, 99.8 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
4️⃣MiB Mem :  15964.0 total,  14746.6 free,    474.6 used,    742.8 buff/cache
MiB Swap:   4096.0 total,   4096.0 free,      0.0 used.  15224.2 avail Mem

PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
897 root      20   0    7792   3772   3172 R   1.0   0.0   0:00.14 top
  1 root      20   0  165740  11032   8100 S   0.0   0.1   0:00.24 systemd
```

1️⃣ CPU의 상태를 확인하는 지표
2️⃣ 몇개가 실행되고, 몇개가 수면이고, ...
3️⃣ us: user, sy: system, ni: , id: idle, wa: wait, hi: , si: , st
database의 경우, user가 높아야 정상인데, 만약 system이 높다면 비정상이므로 원인분석 필요
wait이 많다면 대부분 disk I/O가 원인
4️⃣ 메모리 관련 
주의: 가용메모리는 `free`가 아니라 `avail Mem`이다.

### vmstat

메모리 누수 체크

```shell
vmstat -w -a 1
```

### netstat

네트워크 지표

receive가 찰 때는 db엔진에서 처리를 못하는 경우
send가 찰 때는 client에서 처리를 못하는 경우

```shell
netstat -na
Active Internet connections (servers and established)
Proto ✅Recv-Q Send-Q✅ Local Address           Foreign Address         State       
tcp        0      0 127.0.0.1:5432          0.0.0.0:*               LISTEN      
tcp        0      0 127.0.0.1:5433          0.0.0.0:*               LISTEN      
netstat: /proc/net/tcp6: No such file or directory
udp        0      0 127.0.0.1:59409         127.0.0.1:59409         ESTABLISHED 
udp        0      0 127.0.0.1:35882         127.0.0.1:35882         ESTABLISHED 
netstat: /proc/net/udp6: No such file or directory
netstat: /proc/net/raw6: No such file or directory
Active UNIX domain sockets (servers and established)
Proto RefCnt Flags       Type       State         I-Node Path
unix  2      [ ACC ]     STREAM     LISTENING         88 /tmp/.s.PGSQL.5432
unix  3      [ ]         DGRAM      CONNECTED         37 /dev/log
unix  2      [ ACC ]     STREAM     LISTENING        294 /tmp/.s.PGSQL.5433
unix  3      [ ]         STREAM     CONNECTED        153 
unix  3      [ ]         STREAM     CONNECTED        297 /tmp/.s.PGSQL.5432
unix  3      [ ]         STREAM     CONNECTED        154 /tmp/.s.PGSQL.5432
unix  3      [ ]         STREAM     CONNECTED        296 
unix  2      [ ]         DGRAM      CONNECTED         38 
```



### ps x

현재 접속한 유저들의 모든 프로세스를 보자



### activity

db의 모니터링 근간이 됨

```sql
select * from pg_stat_activity limit 1 \gx
-[ RECORD 1 ]----+------------------------------
datid            | 
datname          | 
pid              | 113
leader_pid       | 
usesysid         | 10
usename          | postgres
application_name | 
client_addr      | 
client_hostname  | 
client_port      | 
backend_start    | 2022-12-13 20:59:38.900589+00
xact_start       | 
query_start      | 
state_change     | 
wait_event_type  | Activity
wait_event       | 1️⃣LogicalLauncherMain
state            | 
backend_xid      | 
backend_xmin     | 
query_id         | 
query            | 
backend_type     | logical replication launcher
```

1️⃣ wait_event가 lock인 경우



### lock monitoring

```
🟢
begin;
update t set a=2;
🔵
begin;
update t set a=2;
⚫
ps x
select pid, mode, granted from pg_locks;
select pid, state, wait_event_type, wait_event from pg_stat_activity;
select pg_blocking_pids(${PID});
```



### query statement monitoring

사용했던 쿼리들의 자세한 정보를 볼 수 있는 확장 모듈에서 제공하는 뷰
일반적으로 항상 포함하여 운영한다.

```shell
```



### etc

pg_stat* 로 시작하는 여러 서버 통계 정보 뷰들, 마흔개 정도다. 그때그때 상황에 맞춰 어떤 뷰를 봐야할지 판단은 해야하기에, 어떤 것들이 있는지는 알고 있어야한다.



### tools

Prometheus : Prometheus는 기본 설정이 15초 간격으로 자료를 수집한다. 수집 주기 변경이 필요하거나, 그 수집한 자료를 기본 tsdb가 아닌 다른 저장소에 보관하는 것이나 dba들이 많고, 모니터링을 지켜보는 인원들이 많고, 중앙에서 전사 DB를 체크해야할 경우, tsdb대신 다른 좋은 db엔진을 활용해서 세팅하는 것을 추천한다.

---

운영하면서 나만의 쿼리들을 가다듬으면서 사용하는 뷰만 사용하게되는데
버전별로 계속 값이 바뀌기 때문에 공식가이드를 followup해야한다.