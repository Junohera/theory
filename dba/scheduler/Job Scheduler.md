[toc]

# Job Scheduler

> OS에서는 스케쥴 작업을 crontab으로 했지만,
> DBMS관점에서도 마찬가지로 스케쥴 작업을 수행할  수 있다.

| 방식           | 버전  | 복잡도 | 다양한 기능 | OS 명령어 | 활용 판단                                         |
| -------------- | ----- | ------ | ----------- | --------- | ------------------------------------------------- |
| DBMS_JOB       | old   | low    | 미제공      | X         | 간단하고 단순할 경우                              |
| DBMS_SCHEDULER | >=10G | high   | 제공        | O         | 복잡하거나 DBMS_JOB에 없는 기능을 사용해야할 경우 |

---

## DBMS_JOB

> PL/SQL 구문, stored procedure에 대해서만 등록 가능(os 작업 불가)
> SNP 백그라운드 프로세스에 의해 동작(job_queue_processes) 파라미터 확인 가능

**등록 갯수 조회**

```sql
select *
  from v$parameter
 where name = 'job_queue_processes';
```

### properties

| 속성      | 설명                        |
| --------- | --------------------------- |
| submit    | 새로운 작업등록             |
| remove    | 삭제                        |
| change    | 변경                        |
| next_date | job에 등록된 작동 시간 변경 |
| interval  | 주기                        |
| what      | 수행할 procedure            |
| run       | 수동으로 등록된 job을 동작  |

### command

```sql
DBMS_JOB.submit(
)
```

## DBMS_SCHEDULER

> DBMS_JOB보다 더 자세한 작업명령 가능(작업시간, 작업형태 등 ...)
> OS 프로그램에 대한 스케쥴링 가능