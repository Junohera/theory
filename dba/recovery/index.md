- 모든 복구는 불완전 복구
- 사고 발생시 해당 시점을 정확히 파악
- 개발 단계일 경우, 일반적으로 복구를 안하는 정책유지
  단, 개발하는데에 지장이 크게 오는 경우 예외적으로 협의하에 복구 지원
- language 별 복구 컨셉

  - dml

    - just rollback

  - ddl

    - 단순 회귀

      - rollback datafile -> 복구

      - rest logs -> open을 위한 로그 다운그레이드

      - open

    - for almost 완전 복구

      - ????

  