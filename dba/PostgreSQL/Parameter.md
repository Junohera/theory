# Parameter

### 개요

> 목적
>
> 1. 쿼리 튜닝
> 2. 서버 튜닝

퍼포먼스 향상 100% 중, 
`쿼리 튜닝:서버 튜닝=90:10` 이라고 생각한다.
(=)`서버 튜닝`은 미미하긴 하다.)

다만, 이미 모든 `쿼리 튜닝`되었다고하면 남은건 `서버 튜닝`을 해야하므로
좀 더 퍼펙트한 데이터베이스를 만들고자 하면 `서버 튜닝`도 간과해서는 안된다.

알지 못하는 상황이라면
보통은 모든 쿼리가 최적화되어 있으므로
함부로 서버 환경 설정 최적화를 건드리진 않는다.

---

### 반영 우선순위

- SET : 현재 접속 세션

- ALTER ROLE : 해당 롤(사용자)

- ALTER DATABASE : 해당 데이터베이스

- ALTER SYSTEM: 서버 (postgresql.auto.conf 파일에 저장됨)

- postgresql.conf : 환경 설정 파일
  (auto.conf가 우선순위 높고, 동일값에 대해선 나중에 설정된 값이 적용되는 부분 주의)



### 파라미터 성격

1. 동/정적 : 재기동 필요
2. 적용 우선순위



###  성능과 관계된 주요 설정들

- checkpoint_completion_target: checkpoint_timeout 간격의 몇 % 시간 동안 분산할지
- checkpoint_timeout: 다음 체크포인트 작업 시간
- work_mem: 세션의 쿼리 실행시 사용하는 정렬 작업 메모리(가장 신경많이)
- maintenance_work_mem: CREATE INDEX, VACUUM 작업에서 사용할 메모리(남는 자원 전부)
- min_wal_size, max_wal_size: WAL 최소, 최대 크기(왠만한 서비스는 2GB로 충분)
  너무 작으면 빈번한 체크포인트 -> 성능저하, 너무 크면 내려쓰는 단위가 커짐
- shared_buffers: 공유 버퍼(통상 25%)
- fsync: on = 디스크 동기화, off = wal 버퍼까지만
  (임시 대용량 DML일 경우, 잠시 off 가능하지만 RDB 철학에 맞지않음. -> 임시 방편)
- synchronous_commit: on = 디스크 동기화, off = os 캐시까지만
  (리눅스 또한 내부적으로 버퍼를 두고 실제로 디스크에 내려쓰는 행위는 lazy하게 처리된다. 하지만 현대시대의 환경에서(네트워크, memory, disk 성능) 굳이 신경쓰지 않아도 되므로 os의 캐시까지만 해도 무방)



### 모든 환경 설정 확인

pg_settings 뷰: 모든 환경 설정 관련 정보 보기



### 로그 관련 설정들

- log_line_prefix: 로그에 남길 각종 부가 정보들 (설명서 참조)
  로그분석을 할 경우, 반드시 해야하는 부분
  지금 당장 로그 분석을 하지 않더라도 반드시 해야하는 부분
- log_min_duration_statement: 실행 시간이 일정 이상 걸린 쿼리를 기록함, 쿼리 최적화 작업이나, 쿼리 패턴을 분석하는 유용
  500ms(일반적인 스타트업)
  200ms(민감할 경우)
- log_temp_files: 일정 크기 이상의 임시 파일을 사용하는 쿼리를 기록함, 쿼리 최적화 작업이나, work_mem 최적값 찾는데 유용
- log_statement: ddl 구문 로그 남기는 용도
- log_lock_waits: 잠금 획득을 위해 일정 시간 이상 기다린 쿼리를 기록함

---

🎈 **대부분의 설정값은 `안전성`과 `성능`을 맞바꾸는 설정들이다.**