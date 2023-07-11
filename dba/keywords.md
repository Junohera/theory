[toc]

### RAC

**R**eal **A**pplication **C**lusters

> = cluster
> = Grid

### DBMS

Memory + Disk

> single instance => 1 memory

### SID

**S**ervice **I**dentifier

### Schema

User's space, Object

### External Execute Query

1. enter: `sqlplus ${USER}/${PASSWORD}`
2. feedback off: `set feedback off;`
3. run: `@${FILENAME}.sql`

#### Set Date Format 

```sql
alter session set nls_date_format = 'YYYY/MM/DD';
alter session set nls_date_language = 'american';
```

### PGA

> **P**rogram **G**lobal **A**rea
> **P**rivate **G**lobal **A**rea

### ANSI

>  **A**merican **N**ational **S**tandards **I**nstitute

### Sub query

**by position**

- Scala
- Inline View
- General

**by form**

- Single row
- Multiple row
- Multiple column
- Correlated 

### sql

- `DDL`: Data Definition Language
- `DML`: Data Manipulation Language
- `DCL`: Data Control Language
- `TCL`: Transaction Control Language
- `DQL`: Data Query Language

### CTAS

> create table as select

### Indexes 

```sql
select ui.index_name												as "indexName",
       uic.column_name												as "columnName",
       ui.table_name												as "tableName",
       ui.table_owner												as "scheme",
       decode(ui.uniqueness, 'UNIQUE', 'O', 'X') 					as "isUnique",
       decode(ui.status, 'VALID', 'O', 'X') 						as "isUsable",
       decode(ui.visibility, 'VISIBLE', 'O', 'X') 					as "isVisible",
       decode(ui.index_type, 'FUNCTION-BASED NORMAL', 'O', 'X') 	as "isFunc",
       decode(uic.descend, 'ASC', 'O', 'X') 						as "isAsc",
       (select round(sum(bytes)/1024/1024, 2)
          from user_segments 
         where segment_name like '%'||ui.index_name||'%')       	as "size (MB)"
  from user_indexes ui,         -- 소속 유저 인덱스 집합
       user_ind_columns uic,    -- 소속 유저 인덱스 컬럼
       user_segments us         -- 소속 유저 스토리지 정보
 where ui.table_name = uic.table_name
   and ui.index_name = us.segment_name
   and ui.index_name like 'IDX_%'
   and ui.table_owner = 'SCOTT'
 order by ui.table_name, uic.column_position;
```

### query plan

```shell
alter session set statistics_level=all;
select * from table(dbms_xplan.display_cursor(null, null, 'allstats last'));
```

### Index Split

> B-tree index에서 새로운 index key가 들어왔을 때 기존에 할당된 블록 내에 저장할 영역이 없어 새로운 블록을 할당하는 것
>
> 인덱스 스플릿은 새로 들어오는 index key 데이터에 따라 2가지 방식으로 이루어집니다

###### 50:50 index split

>  index key값이 기존의 index key 값에 비해 제일 큰 값이 아닌 경우 발생.
> 기존에 존재하던 old block과 새로운 new block에 50%씩 데이터가 채워져 스플릿이 발생하는 것을 말합니다. 
> **최대값이 아닌 값이 들어오면 old와 new block 중 어느 곳에 들어갈 지 모르기 때문**에 50:50으로 스플릿을 합니다.

###### 90:10 index split (99:1 or 100:0 split)

> index key값이 기존의 index key 값에 비해 제일 큰 값이 들어올 경우 90/10 block split이 발생.
> New block에는 새로 추가된 키 값만이 추가됩니다. 
> 즉, 기존의 꽉 찬 old block의 키 값을 재분배하지 않으며 index key 값이 단방향으로 증가하면서 키 값이 삽입되는 경우 발생합니다.
> **최대값인 인덱스 키 값이 들어오면** 계속 큰 값이 들어올 가능성이 높기 때문에 90:10으로 스플릿을 합니다.

### Data Migration

> 1. upgrade or downgrade version
> 2. update statistics information
> 3. change DBMS

**일반적으로 선호하는 시나리오**

 1. 물리적 테이블 생성(테이블 스페이스) 생성
    - 때에 따라 인덱스 생성을 이 단계에서 진행할 수 있음.
      => 이 경우, 데이터 COPY이전에 INDEX UNUSABLE 처리필수
    
 2. 데이터 COPY(보통 이관용 프로그램을 사용)

 3. 이관 후속작업
    ```sql
    CREATE INDEX
    CREATE CONSTRAINT
    GRANT PERMISSION
    ```

**※ INDEX UNUSABLE 주의사항**

1. INDEX UNUSABLE 실행
2. TRUNCATE 실행
3. 1번에서 UNUSABLE했던 INDEX들이 다시 USABLE상태로 되돌아옴.
=> 시나리오 검토잘하고, 절차별 앞뒤로 확인

### View

- `Simple View`
- `Composite View`
- `Data DIctionary View`

### Regex

**특수기호**

- `^`: 시작
- `$`: 끝
- `.`: 한글자
- `+`: 1회 이상
- `\`: 무력화

**문자**

- `[[:alpha:]]`
- `[a-z]`
- `[a-Z]`
- `[A-z]`
- `[a-zA-Z]`
- `[가-힣]`

**숫자**

- `[[:digit:]]`
- `[0-9]`
- `\d`

문자 **또는** 숫자

- `[[:alnum]]`
- `\w`

#### methods

1. `regexp_replace`: 문자열 치환 및 삭제
2. `regexp_substr`: 문자열 추출
3. `regexp_instr`: 문자열의 위치 추출
4. `regexp_like`: 문자열을 선택(where절에서만 사용)(=grep)
5. `regexp_count`: 문자열 수 반환



### quota

> 할당량

- user당 tablespace별 부여가능
- 특정 tablespace 내 허가된 사용량
- 다른 유저의 DML을 통해 나의 quota를 초과하는 경우, 나의 quota를 늘려주어야한다.

### tablespace

- table의 집합, 영역(물리적 사이즈를 갖지 않음)
- **하나의 table은 반드시 하나의 tablespace**에 귀속되어야한다.

tablespace는 실제로 물리적인 디스크 공간을 직접 할당하진 않지만
tablespace를 구성하는 **물리적 파일인 *datafile*들의 사이즈의 합을 통해**
**tablespace의 disk usage를 확인할 수는 있음**
(마치 linux에서 directory의 사이즈는 없지만, directory안에 포함된 파일들의 사이즈를 통해 알 수 있는 것 처럼)

#### **default tablespace**

- user 생성시 user 단위 선언 가능(생략시 users tablespace가 자동 지정됨)
- 특정 user가 테이블 생성시 tablespace를 지정하지 않을 때 자동 지정되는 tablespace

🔥 DBA라면 유저 생성시 반드시 default tablespace를 명시해야한다.

```sql
create user ?
default tablespace ???
```

#### **temporary tablespace**

> 2차 정렬 공간, ...

- 정렬을 위한 공간(디스크에서 수행되므로 느리게 진행됨)
  물론 1차정렬은 메모리인 PGA에서 진행됨.
- 다른 역할도 있지만, 지금 단계에서는 정렬공간으로만 알고있으면 됨.

### 정렬 수행

1. PGA
2. temporary tablespace

### DBA관점에서의 Storage 관리

- tablespace: 논리적인 영역(마치 directory)
- quota: 유저별로 갖는 논리적인 수치(limit)
- datafile: 물리적인 영역

위의 세가지를 고려하여 적절하게 증감

### **high availablity**

> 이중화

**목적**

항상 사용할 수 있는 상태로 만들기 위함

- active active

  - 서버가 모두 활성화 상태
  - 모두 활성화 되어 동작하는 구성

- active standby
  - 활성화 서버와 대기 서버
  - 기본적인 이중화 방법
    - 두 대 중 하나는 활성화되어 동작하고, 나머지 하나는 장애 등의 경우에 대비하여 대비시키는 구성
    - 장애 발생을 감지하여 Active 장비가 죽게되면, Standby 장비가 Failover가 일어나 Active로 변경
  - 종류
    - Hot Standby: Standby 장비 가동 후, 즉시 사용 가능
    - Warm Standby: Standby 장비 가동 후, 이용이 가능하게 하기 위해서 준비가 필요
  
    - Cold Standby: 평소 Standby 장비를 정지시켜두며, 필요시 직접 켜서 구성
  

| a      | Active Active | Active Standby |
| ------ | ------------- | -------------- |
| 복잡도 | high          | low            |
| 처리율 | high          | low            |

### db hang

1. disk 공간이 꽉 찼을 때(추가세션조차 생성 불가)

```shell
# disk
df
```

2. LGWR가 참조하는 online logfile이 물리적으로 없거나 손상되었을 경우
