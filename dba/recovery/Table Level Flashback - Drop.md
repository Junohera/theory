# Table Level Flashback - Drop

기본적으로 drop table로 테이블 삭제시
내부적으로는 rename이 발생된다.

그리고 해당 정보를 recyclebin 공간에 보관하는데
만약 recyclebin의 공간이 부족한 경우, drop table 내용이 삭제될 수 있음(비교적 오래 보관되는 편)

---

## ☠ 주의사항

**purge 옵션으로 drop table시 recyclebin 공간에 보관되지않음**

**system 계정 소유의 테이블은 recyclebin 공간에 보관되지 않음**



