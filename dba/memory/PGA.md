# PGA[^PGA]

- SGA는 DB가 기동되면 사용자 프로세스를 종료하더라도 남아 있는 공간
- PGA는 하나의 server process가 기동되면 하나의 PGA가 할당
- server process가 종료되면 할당한 영역을 반환
- pga_aggregate_target으로 전체 PGA 사이즈 지정

## Private SQL Area

- bind 처리된 값 저장
- user process의 query가 갖는 임시정보 저장

## SQL Work Area

- sort나 hash 관련 작업을 수행하는 공간
  - `order by, union, group by, distinct, ...`
  - `PK, UK, IDX`


# 🎁tip

**세션별 PGA 사이즈 확인**

```sql
SELECT S.SID,
       S.SERIAL#,
       P.SPID AS "OS PID",
       S.USERNAME,
       S.MODULE,
       S.TERMINAL,
       S.SQL_ID,
       S2.SQL_TEXT,
       P.PGA_USED_MEM/1024/1024 AS "SIZE(MB)"
  FROM V$PROCESS P,
       V$SESSION S,
       V$SQL S2
 WHERE S.PADDR = P.ADDR
   AND S.SQL_ID = S2.SQL_ID(+)
 ORDER BY "SIZE(MB)" DESC;
```



---

[^SGA]: **S**hared|**S**ystem **G**lobal **A**rea
[^PGA]: **P**rogram|**P**rivate|**P**ersonal **G**lobal **A**rea