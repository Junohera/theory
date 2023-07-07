[toc]

---

# 커서 공유

> Library Cache에 존재하는 커서가 "커서 공유"
>
> Cursor ? [^Cursor]

- 한번 수행된 SQL 문장의 실행계획과 관련 정보를 보관
- 재활용을 통해 ~~Hard parse([^hard parse])~~가 아닌 ***Soft parse([^soft parse])***로 수행하도록 함.

**1. 해시함수는 대소를 구분하므로 대소가 달라지면 해시값이 달라짐**

> ```sql
> select * from emp; -> hash fun -> 2343
> select * from emp; -> hash fun -> 2343 ( 실행계획 공유 ✅)
> select * from emp; -> hash fun -> 2344 ( 실행계획 공유 ❌)
> ```

**2. literal SQL(상수를 그대로 노출하는 SQL)의 경우 해시값이 달라지므로 커서공유를 할 수 없음**

> ```sql
> select * from emp where empno = 9999; -> hash fun -> 2222
> select * from emp where empno = 8888; -> hash fun -> 3333
> ```

**3. literal SQL에 대한 대응 방법**

**- 바인드 변수 처리**

- 상수를 그대로 노출시키지 않고, 

**- 커서공유 방법을 force로 변경**

- force로 변경하게 되면 항상 커서를 공유함
  - 이에 따라, Library Cache Hit Ratio가 높아짐(지양)

# DQL의 실행원리

>  parse -> bind -> execute -> fetch

**parse**

- Syntax Check(문법) + Semantic Check(객체)
- 자주 사용되는 객체 정보는 Dictionary Cache에 보관하여 쿼리성능 향상
- 오류가 없을 경우, 입력 구문을 해시 함수의 반환된 해시값으로 라벨링 후 Library Cache에 저장
- 해시값이 같을 경우 동일한 SQL로 판단하여 실행계획을 공유함



# DML의 실행원리

parse -> bind -> execute -> fetch

---

[^Dictionary Cache]: 객체(테이블, 컬럼, 사용자 정보 등)의 정보를 저장(=**Data Dictionary Cache**)
[^library cache]: SQL 명령문, 구문 분석 트리, 실행계획 정보를 갖는 공간 실행계획 정보를 갖는 공간, LRU알고리즘으로 관리됨 SGA.Shared pool.Librach cache
[^library cache hit ratio]: 실행계획 재사용 비율(=library cache에 적중한 비율), library cache 메모리의 공간이나 구조가 비효율적이거나 literal sql이 무분별하게 사용되었을 경우 등이 주요 저하 요인
[^Cursor]:  메모리에 데이터를 저장하기 위해 만든 임시 저장공간(공유 커서, 세션커서, 어플리케이션 커서)
[^soft parse]: 메모리에 재사용 가능한 실행계획이 있을 경우, Library Cacht Hit되어 쿼리가 빠르게 수행
[^hard parse]: 메모리에 재사용 가능한 실행계획이 없거나 공유할 수 없을 때, Optimazer가 Data Dictionary등을 참조하여 실행계획을 다시 설계한 후, 진행하므로 쿼리가 느리게 수행
