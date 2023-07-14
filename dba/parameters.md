#### **shared_pool_size**

공유 메모리 사이즈

0일 경우, 직접 설정한 값이 없는 것을 의미하므로 자동으로 메모리관리를 사용중이라는 의미
(AMM[^AMM] 또는 ASMM[^ASMM])

#### **sga_max_size**

##### **sga_target**

ASMM 설정값: 0이상이면 사용, 0이면 미사용

#### **memory_target**

AMM 설정값: 0이상이면 사용, 0이면 미사용

#### **large_pool_size**

대규모 메모리 할당을 위해 제공하는 영역의 사이즈를 설정하는 값 (default `0`)

#### **java_pool_size**

oracle에서 java 사용시 사용되는 영역의 공간을 설정하는 값 (default `24MB`)

#### **deferred segment creation**

- true
  - 최초 테이블 생성시 데이터가 입력되기 전까지 저장공간(**segment**)이 할당되지 않음.
  - 빈 테이블에 시퀀스를 가지고 데이터 입력 시도시 공간이 없어서 잠시 대기, 그 사이에 해당 테이블에 대한 저장공간을 마련함
  - 문제는 최초입력 시도시 사용되었던 시퀀스 번호는 재사용이 불가하므로 그 다음번호>로 입력이 됨.
  - 따라서, 데이터가 없는 테이블이더라도 이미 예전에 입력시도가 있었던 테이블(commit 여부와는 무관)에는 시퀀스 번호가 그대로 입력이 가능함.

예시: insert 행위를 한번도 하지 않은 테이블에 시퀀스를 하여 insert시도를 할경우, 시작번호가 1000번이었을 경우, 1001로 입력됨.

#### **db_cache_size**

#### **log_buffer**

redo log buffer의 사이즈 변경[동적 변경 불가]

#### **undo retention**

commit 수행후에도 다른 서버 프로세스가 덮어쓰지 못하도록 막아주는 시간(default: `900s -> 15M`),
단, undo segment의 여분이 있을 경우에만 적용되고 여분이 없을 경우 undo retention이 무시되고 새로운 트랜잭션 수행을 위해 flush

#### **undo retention guarantee**

아무리 장애가 발생하여도, undo retention을 보장해주는 파라미터 (default: `NOGUARANTEE`)





# foot notes

[^ASMM]: Automatic Shared Memoery Management
[^AMM]: Automatic Memory Management

