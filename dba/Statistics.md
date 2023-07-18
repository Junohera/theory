[toc]

# Statistics

## **통계정보 수집**

> optimizer가 실행계획을 세울 때, 사용하는 테이블의 기초 자료
> 테이블 구성 block 정보, row수, 각 컬럼마다의 histogram(density, distinct value, ...)

### 통계정보 수집 방법

> 빅테이블일수록 엄청난 시간을 소요할 수 있음.
> 옵션을 조절하여 실제 업무에 사용하면 성능향상을 다른 방법들에 비해 보다 쉽게 진행할 수 있음

- [ ] 1. analyze
     오래된 방법이며, 간단한 옵션으로 사용가능해 실제 업무로 사용하기엔 무리가 있음.

     ```sql
     analyze table scott.stg_test1 compute statistics;
     ```

- [ ] 2. dbms_utility package

- [x] 3. dbms_stats package
     oracle 권고사항이기도 하고, 여러 옵션을 사용가능하므로 실제 업무에서 사용할 것

     ```sql
     exec dbms_stats.gather_table_stats(ownname=>'scott',												-- 소유자명
                                        tabname=>'account',											-- 테이블명
                                        estimate_percent=>100,										-- 수집비율
                                        CASCADE=>TRUE,														-- 인덱스 통계수집 여부
                                        granularity=>'ALL',											-- 통계수집 대상
                                        method_opt=>'FOR ALL COLUMNS SIZE 1',		-- histogram 생성 옵션
                                        degree=>8,																-- 병렬수행
                                        no_invalidate=>FALSE);										-- physical plan 삭제 여부
     ```

## granularity

> 통계수집 대상

### 1. all

전체

### 2. global

파티션을 제외한 테이블 통계 정보만 수집

### 3. partition

파티션 수준의 통계 정보만 수집

## 통계정보 수집 쿼리

```sql
select /*+ RULE */
       'exec dbms_stats.gather_table_stats(ownname=>'||chr(39)||OWNER||chr(39)||',tabname=>'||chr(39)||table_name||chr(39)
    || ',estimate_percent=>'
    || case when MBYTES < 10    then '100'
            when MBYTES < 100   then '20'
            when MBYTES < 1000  then '5'
            when MBYTES < 5000  then '5'
            when MBYTES < 10000 then '1'
            else '1'
       end
    ||',CASCADE=>TRUE,granularity=>'||chr(39)||'ALL'||chr(39)||' ,method_opt=>'||chr(39)||'FOR ALL COLUMNS SIZE AUTO'||chr(39)
    ||' ,degree=>'||
       case when MBYTES <  1000  then '8'
            when MBYTES <  5000  then '8'
            when MBYTES <  10000 then '16'
            when MBYTES >= 10000 then '32'
       end
    || ',no_invalidate=>FALSE);' as STMT
  from (select OWNER, TABLE_NAME, sum(MBYTES) MBYTES
          from (select OWNER, SEGMENT_NAME TABLE_NAME, PARTITION_NAME, round(sum(BYTES)/1024/1024,0) MBYTES
                  from DBA_SEGMENTS seg
                 where 1=1
                   and OWNER        like 'SCOTT'
--                   and SEGMENT_TYPE like '%'
--                   and SEGMENT_NAME like '%'
--                   and length(SEGMENT_NAME) = 14
                 group by OWNER, SEGMENT_NAME, PARTITION_NAME)
         group by OWNER, TABLE_NAME)
 order by MBYTES desc
;
```

