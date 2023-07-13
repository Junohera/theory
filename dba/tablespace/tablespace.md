[toc]

# tablespace

> logical boundary
>
> > if file == {table, index, ...}:
> >
> >   tablespace is directory.

<img src="./assets/image-20230713110848037.png" alt="image-20230713110848037" style="zoom:50%;" />

## 특징

- 여러 객체를 묶는 논리적 공간 개념
- tablespace는 물리적으로 여러 datafile로 구성
  = tablespace는 반드시 하나 이상의 datafile로 구성

## 종류

### default tablespace

#### **1. system tablespace**

- system01.dbf
- Data Dictionary[^Data Dictionary]들이 저장되어있음

- SYS 계정 소유의 tablespace이지만 소유자인 SYS 계정도 이 테이블의 내용을 변경할 수 없음
- Data Dictionary 테이블 개수 조회
  ```sql
  SQL> select count(*) from dictionary;
  ```

#### **2. sysaux tablespace**

- oracle **성능 튜닝**과 관련된 정보 저장
- AWR 정보 저장

#### 3. temporary tablespace

- **2차 정렬**을 위한 공간(디스크에서 수행되므로 느리게 진행됨)
  물론 1차정렬은 메모리인 PGA에서 진행됨.
- 다른 역할도 있지만, 지금 단계에서는 정렬공간으로만 알고있으면 됨.
- TEMP tablespace가 자동 생성됨(rename하지 않는 경우, 그대로 TEMP로 사용됨)



### **Data Dictionary** 정보

DBMS내 관리되는 모든 객체, 세션, 자원 정보이고, base table이 존재하며 사용자에게는 view 형태로 조회가능하도로 설계 -> data dictionary view

**data dictionary view 종류**

1. **static data dictionary view**: about object, from open

      ```sql
      # user_XXXX : 접속 계정 소유 오브젝트
        select * from user_tables;
      # all_XXXX  : 접속 계정 소유 오브젝트 + 접근 권한이 있는 오브젝트 모두
        select * from all_tables;
      # dba_XXXX  : 모든 오브젝트 조회 가능(단, DBA 권한을 가진 자만)
        select * from dba_tables;
      ```

2. **dynamic performance view**: about performance, from nomount

    ```sql
    # v$___
    select * from dba_views where view_name like 'V_$SESSION%';
    select * from v$session;
    -- origin: v$session, references: v_$session
    ```

---

# foot note

[^Data Dictionary]: 메모리로 구성된 Shared Pool.Data Dictionary Cache의 실제 물리적인 공간
