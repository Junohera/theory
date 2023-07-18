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

1. `all`: 전체
2. `global`: 파티션 제외한 테이블 통계 정보만 수집
3. `partition`: 파티션 수준 통계 정보만 수집