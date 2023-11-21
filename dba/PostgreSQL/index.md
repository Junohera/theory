# PostgreSQL

[toc]

## 소개

> [강의 자료 문서](https://bit.ly/3wsxU43)

### 특징

- client:process = 1:1(다중 프로세스 기반)
  - 다른 db엔진에 비해 shared memory를 많이 할당할 수 없다.

- 비교적 충실한 트랜잭션 처리 - 이상적인 트랜잭션 처리는 없다!

- OS에 의존도가 크다. (ex: cpu사용량이 궁금해? 그럼 os단에서 확인해!)

- 이식성이 완벽하지 않다.

  > ASIS: same OS, same bit, TOBE: same OS, same CPU type, same bit
  >
  > (100% 동일하지 않음. => 동일한 환경을 반드시 유지 => )
  > BINARY 수준에서 완벽 호환 불가(OS단과 CPU칩 유형 반드시 동일하게)

---

## WSL[^ WSL]

> 윈도우에서 리눅스 환경으로 접근하는 방법
> 만약 wsl 환경을 준비하지못하거나 불필요하다면, [crunchydata](https://www.crunchydata.com/developers/playground)에서 확인

1. cmd

2. wsl -l -v
   ```bat
   wsl -l -v
     NAME      STATE           VERSION
   * Ubuntu    Stopped         2✅
   ```

3. 만약 version 2가 확인되지 않는다면(=1이면)

   1. 설정 변경 필요

   2. 명령어 실행(구글링)
      ```bat
      dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
      
      dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
      ```

   3. `wsl --update`(|| `wsl --install`)

   4. os 재기동

   5. 업데이트 확인

   

## 설치

### 설치 유형

1. 수동
2. 자동(package로)



### 설치 유형 확인법

> 확인해야하는 이유
>
> 전혀 다른 libpq 라이브러리를 참조할 수도 있어 버그 유발 가능성이 존재하고,
> 확인하고, 작업하기 위한 위치를 알아야하기 때문.

```shell
# 1. shell 돌입
\! sh
# 2. linux 환경 확인
cat /etc/os-release

# 3. process 확인
ps 
```

```
...
106 postgres 🟢/usr/bin/postgres -D /var/lib/pgsql🟢
108 postgres postgres: checkpointer 
109 postgres postgres: background writer 
110 postgres postgres: walwriter 
111 postgres postgres: autovacuum launcher 
112 postgres postgres: stats collector 
113 postgres postgres: logical replication launcher 
...
```

위의 내용을 통해 postgres의 최상위 프로세스 ID를 확인하고,
최상위 프로세스 ID를 통해 설치된 경로를 파악해야한다.

`rpm || debian || yum`

어떤 방법으로 설치되었는지 알게되면 (현재는 rpm을 예시)
다음과 같은 명령어로 파악가능

`rpm -qa | grep postgresql`



### LD_LIBRARY_PATH 존재 확인

**이유**

미리 설치된 다른 포스트그레스큐엘 관련 파일이 있을 수 있다. 대표적으로 배포판에서 기본적으로 설치되는 postgresql-libs 패키지가 있는데, 이것과 충돌할 수도 있고, 사용자가 임의로 LD_LIBRARY_PATH 설정을 해서 전혀 다른 libpq 라이브러리를 참조할 수도 있기 때문

**확인 방법**

```shell
rpm -ql postgresql14
rpm -ql postgresql14-server
id postgres
ldd /usr/pgsql-14/bin/psql
```

**있을 경우**

ldd 명령으로 libpq 라이브러리 참조를 꼭 살펴보아야한다



## 명령행 도구들

### Server 관점

> 명령행 도구들 목록 보기: `rpm -ql postgresql14-server | grep bin`

1. initdb : 데이터베이스 초기화 도구, 서버를 구성할 때 처음 한 번은 꼭 사용해야한다.
2. pg_controldata: 데이터 클러스터 정보 보기, 백업 복구 때 중요한 정보를 제공한다.
3. **pg_ctl: 기본 서버 관리 도구**
4. pg_upgrade: 메이저 버전 업그레이드 도구
5. postgres: 서버 프로그램 (pg_ctl 명령으로 이 프로세스를 실행하고 중지한다)

### Client 관점

> 명령행 도구들 목록 보기: `rpm -ql postgresql14 | grep bin`

1. pg_basebackup: 온라인 백업 도구
2. pg_dump, pg_restore: dump & restore 도구
3. **psql: 대화형 데이터베이스 조작 도구**
4. vacuumdb: 데이터베이스 청소 도구



## process & transaction 주요 문제상황

### zombie process

client 입장에서 모든 요청에 대해 응답 또는 결과를 확인하고,
client를 정리해야하는게 지극히 상식적인 이야기이지만,
**DBA라면 반드시 모든 요청에 대해 응답 또는 결과를 확인해야한다.**

그렇지 않을 경우, 수행되지 않은 프로세스들이 생겨나고,
이로 인해 초래되는 모든 현상은 책임져야한다.

> todo sequenceDiagram

```bat
# 정상 : 요청에 따른 응답
Client ➡ A ➡ B ➡ C ➡ Server
Client ⬅ A ⬅ B ⬅ C ⬅ Server

# 비정상 : 요청 중, 특정 구간 응답 불능상태 (이 때, 프로세스가 남아있다면 timeout등의 제한에 걸리지 않는 동안 그 누구도 해당 프로세스를 찾거나 죽이기 어려우므로 이것이 좀비 프로세스)
Client ➡ A ➡ B ❌ C ❌ Server
Client ❌ A ❌ B ❌ C ❌ Server
```

### idle in transaction

auto commit이 아닐 경우에
commit이든 rollback을 실행하지 않을 경우, 다음과 같이 프로세스가 계속 남는다.

```shell
begin;
\! ps | grep idle | grep -v grep
130 postgres postgres: postgres postgres [local] idle
163 postgres postgres: postgres postgres [local] idle in transaction💥
```

### after when failure query in transaction

```sql
postgres=# begin;
BEGIN
postgres=*# select 1/0;💥
ERROR:  division by zero


postgres=!# select 1;💥
ERROR:  current transaction is aborted, commands ignored until end of transaction block
postgres=!# select 1;💥
ERROR:  current transaction is aborted, commands ignored until end of transaction block
postgres=!# select 1;💥
ERROR:  current transaction is aborted, commands ignored until end of transaction block
...
```





---



[^ WSL]: Windows Subsystem for Linux
