

![Oracle Instance Lifecycle](../assets/Oracle Instance Lifecycle.png)

## 복구 방식

|           | 방식                        | 방향                     |           | 보관장소      |
| --------- | :-------------------------- | ------------------------ | --------- | ------------- |
| flashback | 과거를 불러옴               | 미래에서 과거(back)      | flashback | only local    |
| recovery  | archive파일들을 하나씩 끼움 | 과거에서 미래로(forward) | archive   | local, remote |



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

      - 시점복구
      - archivelog 적용
      - redo file에 기록된 내용 recovery
      - ...?

- 복구 방법
  - flashback: from future to past
  - archive: from past to future

