### pgsql은 kill을 kill로 하면 안된다

```shell
🟢
psql
select pg_sleep(60);
🔵
ps x
kill -9 837
```

다음과 같이 하게될 경우,
최상위 프로세스를 제외한 나머지 프로세스들이

- postgres: checkpointer 
- postgres: background writer 
- postgres: walwriter 
- postgres: autovacuum launcher 
- postgres: stats collector 
- postgres: logical replication launcher

전부 초기화된다.
최상위 프로세스관점에서 일개의 백엔드 프로세스가 강제로 프로세스가 종료될 경우,
나머지 프로세스들을 전부 신뢰하지 못하는 상황이라 판단해
본인을 제외한 모든 프로세스를 전부 다시 띄우게된다.(하나의 세션을 죽이기 위해 나머지 프로세스들을 전원 초기화하는 상황)

> 실제로 최초의
> ps x를 통해 프로세스 ID들과
> 특정 백엔드 프로세스를 kill 이후
> ps x를 실행한 프로세스 ID들의 
> ID대역이 달라짐 -> 초기화

+ OS관점의 `out of memory`로 kill을 시킬 수도 있음.
  memory가 넘치는 이유 중에 하나는 정리되지 못한 backend process가 그 원인이 될 수도 있다.
  backend process는 처음에는 미미한 메모리만 사용하지만, 오래 될수록 사용하는 메모리는 커진다.



### pg_wal

postgres DB의 사활은 이 부분에 달려있다고 무방.
용량관리를 가장 보수적으로 진행해야하는 부분
90%가 된 시점에는 이미 늦을 수도 있음.
archive가 가득차서 보관을 못하더라도 pg_wal의 최대 사이즈로
대체 작업을 해주긴함. 하지만 pg_wal마저 가득차면 db 작업 불가💥

용량관리 중 가장 우선순위 높은 파트
더불어 예측도 어느정도 할 수 있어야 함.

