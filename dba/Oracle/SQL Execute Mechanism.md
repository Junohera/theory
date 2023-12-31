[toc]

---

# 커서 공유

## Sql : Hash

> 커서와 커서공유를 이해하기전 
> 알아야하는 백그라운드 내용
>
> 🗡 **모든 sql은 내부적으로 hash value로 비교관리**된다.
> 모든 프로그래밍 언어의 런타임시 생성되는 메모리값과 동일한 개념(instance memory address in java, ...)

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



## Cursor [^Cursor]

Library Cache에 존재하는 커서

한번 수행된 SQL 문장의 실행계획과 관련 정보를 보관

## Cursor Share [^Cursor Share]

재활용을 통해 ~~Hard parse([^hard parse])~~가 아닌 ***Soft parse([^soft parse])***로 수행하는 현상을 "커서 공유"이라 한다

## Cursor Share Mode

**`exact`**

**정확하게 일치하는(대소, 띄어쓰기, 상수) 경우만** 커서를 공유(default)

**`similar`**

**비슷한 sql**에 대해 실행계획을 공유하도록(12c deprecated)

**`force`**

**literal 처리된 부분만** 같은 SQL로 인식, 커서를 공유함(대소, 띄어쓰기의 차이가 있을 경우는 다른 SQL로 인식)

>  ~~프로젝트 전원 멍충멍충 주니어일 경우 아니면 지양~~
>  ~~오픈직전 리터럴 SQL의 빈도가 많을 경우, 임시 방편~~

# DQL의 실행원리

>  ⚔ SQL의 실행 과정
>
>  1. parse
>  2. bind
>  3. execute
>  4. fetch

**1. parse**

- Syntax Check(문법) + Semantic Check(객체)
- 자주 사용되는 객체 정보는 Dictionary Cache에 보관하여 쿼리성능 향상
- 오류가 없을 경우, 입력 구문을 해시 함수의 반환된 해시값으로 라벨링 후 Library Cache에 저장
- 해시값이 같을 경우 동일한 SQL로 판단하여 실행계획을 공유함

**2. bind**

- 변수를 입력받은 값으로 바인딩하는 구간

**3. execute**

- 사용자가 원하는 데이터를 1차적으로 **Database Buffer Cache**에 존재 ? **Logical Read** : **Physical Read**
- 이 때, 데이터의 이동 단위는 **block**(**db_block_size** 크기만큼, default: 8K)

**4. fetch**

- 사용자가 원하는 데이터만 골라서 전달하는 행위
- **block 단위로 캐시된 사이즈**와 **사용자가 원하는 데이터의 사이즈**가 다를 수 있으므로, 사용자가 원하는 사이즈로 뽑아주는 행위

## Literal Sql 대응

**1. 바인드 변수 처리**✔

- 상수를 그대로 노출시키지 않고 변수로 변경하는 방법

  ```sql
  select *
    from scott.emp
   where empno = :emp_number;
  ```

**2. 커서공유 방법을 force로 변경**❌

- 어쩔 수 없을 때 임시방편이라 생각

---

[^Dictionary Cache]: 객체(테이블, 컬럼, 사용자 정보 등)의 정보를 저장(=**Data Dictionary Cache**)
[^library cache]: SQL 명령문, 구문 분석 트리, 실행계획 정보를 갖는 공간 실행계획 정보를 갖는 공간, LRU알고리즘으로 관리됨 SGA.Shared pool.Librach cache=-
[^library cache hit ratio]: 실행계획 재사용 비율(=library cache에 적중한 비율), library cache 메모리의 공간이나 구조가 비효율적이거나 literal sql이 무분별하게 사용되었을 경우 등이 주요 저하 요인
[^Cursor]:  일반적으로는 메모리에 데이터를 저장하기 위해 만든 임시 저장공간(공유 커서, 세션커서, 어플리케이션 커서)이라 칭하지만 **DBMS 관점에서는 Shared Pool의 Library Cache 영역**을 커서라 칭함.
[^Cursor Share]: 같은 SQL에 대해(same hash value) Library Cache 영역에 이미 존재하는 실행계획을 공유(재사용)하는 현상
[^soft parse]: 메모리에 재사용 가능한 실행계획이 있을 경우, Library Cacht Hit되어 쿼리가 빠르게 수행
[^hard parse]: 메모리에 재사용 가능한 실행계획이 없거나 공유할 수 없을 때, Optimazer가 Data Dictionary등을 참조하여 실행계획을 다시 설계한 후, 진행하므로 쿼리가 느리게 수행
