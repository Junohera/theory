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

