##### **shared_pool_size**

공유 메모리 사이즈

0일 경우, 직접 설정한 값이 없는 것을 의미하므로 자동으로 메모리관리를 사용중이라는 의미
(AMM[^AMM] 또는 ASMM[^ASMM])

##### **sga_target**

ASMM 설정값: 0이상이면 사용, 0이면 미사용

##### **memory_target**

AMM 설정값: 0이상이면 사용, 0이면 미사용

**large_pool_size**

대규모 메모리 할당을 위해 제공하는 영역의 사이즈를 설정하는 값 (default `0`)

**java_pool_size**

oracle에서 java 사용시 사용되는 영역의 공간을 설정하는 값 (default `24MB`)

# foot notes

[^ASMM]: Automatic Shared Memoery Management
[^AMM]: Automatic Memory Management

