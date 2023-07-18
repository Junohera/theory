# Segment Storage

## FLM

- 9i 이전의 세그먼트 관리 방식
- system, undo, temp tablespace
- 수동으로 DBA가 PCTFREE, PCTUSED를 관리
- segment space를 **freelist**를 통해 관리

## ASSM

- 9i 이후 `default`
- 자동으로 PCTFREE, PCTUSED를 관리
- segment space를 **bitmap**(트리구조)을 통해 관리

---

# footnotes

[^FLM]:Free List Management
[^ASSM]: Automatic Segment Space Management