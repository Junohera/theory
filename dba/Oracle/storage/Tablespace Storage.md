# Tablespace Storage

## DMT

- 9i이전
- free block, dirty block 목록을 **dictionary**로 관리
- **DBMS 전체적**으로 관리
- 전체범위에서 블럭을 찾다보니 비효율적인 접근 발생
- 새로운 블록을 할당받는게 매우 느렸다고함.
- 성능 저하 발생으로 10g 이후부터는 권고하지 않음.

## LMT

- `default`
- free block, dirty block 목록을 **tablespace**로 관리

---

# footnotes

[^DMT]:Dictionary Managed Tablespace
[^LMT]:Locally Managed Tablespaces