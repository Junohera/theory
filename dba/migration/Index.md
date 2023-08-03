# Migration

- 장비교체(os, disk, dbms)등의 이유로 새로운 DB 환경 구성이 필요할 경우
  기존 DB에서 새로운 DB로의 데이터 전환이 필요
- DB 버전 upgrade로 새로운 DB 구축 및 테스트 필요한 상황

- general flow
  1. server
  2. disk
  3. tablespace
  4. user
  5. table
  6. data
  7. permission
  8. constraints
  9. index
  10. synonym