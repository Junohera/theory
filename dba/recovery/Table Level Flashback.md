[toc]

# Table Level Flashback

> dml로 인해 데이터 손실이 발생한 경우
> 특정 시점의 테이블  단위로 이전 이미지를 공급, 이를 통해 복구 가능

**전제조건** 

1. enabled flashback

**flashback on/off 여부**

```sql
SQL> select flashback_on from v$database;

FLASHBACK_ON
------------------
NO
```

## 종류

1. flashback query✅
   
   > **query를 사용한 복구**
   >
   > 쿼리를 작성해야하는 번거로움이 있지만,
   > 추가적인 조치를 취하기가 쉽고, 응용하기가 좋음.
   > (또다시 잘못된 dml을 수행하거나 CTAS등을 활용가능)
2. ~~flashback table~~
   
   > **바로 특정 시점의 테이블 데이터로 변경**
   >
   > 쿼리를 작성할 필요없어 가장 편함.
   > 응용조치를 할 수 없음.
   > 블록의 이동에 영향을 주기 때문에 1번(`flashback query`)을 권장하고, 사용하더라도 rowmovement를 다시 disable 시켜주는게 좋다.
   >
   > ### 추가 전제조건
   >
   > - rowmovement enable

## 명령어

TODO:
