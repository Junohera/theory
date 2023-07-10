# ASMM[^ASMM]

> 10g New Feature

**자동 관리 범위**

| 영역 | 자동 관리 여부 |
| ---- | -------------- |
| PGA  | false          |
| SGA  | true           |

- shared_pool_size, java_pool_size, db_buffer_cache 사이즈는 최소값 의미
- MMAN 프로세스가 5분마다 부하 상황 체크, 부족한 메모리에 가용 메모리를 할당
- sga_target = 0
  1. memory_target = 0 ? manual memory management
  2. memory_target > 0 ? enable automatic memory management[^amm]
- sga_max_size는 ASMM, AMM기능
  1. `off`
     sga가 갖는 최대 사이즈이며, 이 안에서 내부 메모리들의 사이즈가 할당되어야 함
  2. `on`
     sga가 갖는 최소 사이즈이며, 이 안에서 내부 메모리들의 사이즈가 자동할당됨



# AMM[^AMM]

> 11g New Feature

**자동 관리 범위**

| 영역 | 자동 관리 여부 |
| ---- | -------------- |
| PGA  | true           |
| SGA  | true           |

memory_target = 1200이면 메모리를 수동관리함을 의미(0보다 크면 AMM 기능 활성화)



조회 쿼리

```sql
select *
  from v$parameter
 where name in ('memory_target',
                'sga_max_size',
                'sga_target',
                'shared_pool_size',
                'java_pool_size');
```





# foot notes

[^ASMM]: Automatic Shared Memoery Management
[^AMM]: Automatic Memory Management

