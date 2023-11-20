# Directory

[toc]



## PGDATA

```shell
ps x | grep postgres | grep -v grep
106 postgres /usr/bin/postgres -D ✨/var/lib/pgsql✨
108 postgres postgres: checkpointer 
...
```

```shell
cd /var/lib/pgsql/
pwd
/var/lib/pgsql => PGDATA
```



## TIP

- wal을  쓸 수 없는 상황일 경우, read only로 돌입되는 것이 아니라 db 자체가 종료된다.
  용량이 부족하여 다시 띄우지도 못함 => 용량관리의 중요성을 인지시키기 위한 가장 대표적인 사례

- vm(visibility map)이 없다면, vacumm을 실행할 수 없음.
  대표적으로 insert만 진행하는 테이블의 경우, vacumm이 필요 없을 수 있으나
  wrap around 현상이 발생하게 되면 많은 코스트를 발생할 수 있으므로, insert의 dml만 존재하는 테이블이더라도 vacumm을 진행할 수 있게 관리를 하는 것이 좋다(15쯤부터는 자동으로 실행됨)

---

[^WAL]: Write Ahead Log
[^ vm]: visibility map
[^ fsm]: free space map
