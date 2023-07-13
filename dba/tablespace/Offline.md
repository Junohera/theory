# Offline

## 특징

- offline은 **tablespace**와 **datafil** 단위로 가능
- 읽기와 쓰기 작업 금지
- 주로 작업, 장애복구 등을 위해 설정

|                | 체크포인트 발생여부 | online시 recover 필요 여부 |
| -------------- | ------------------- | -------------------------- |
| **tablespace** | ✅                   | ❌                          |
| ~~datafile~~   | ❌                   | ✅                          |

## 모드

### 1. normal Mode

- datafile 이동

```sql
alter tablespace users offline;
```

### 2. Temporary Mode

- tablespace의 datafile 중 하나라도 이상이 있을 경우 정상 offline 불가능
```sql
alter tablespace users offline temporary;
```

### 3. Immediate Mode

- tablespace의 datafile에 장애가 났을 경우
- 반드시 archive log mode 일 경우에만 사용
- 나중에 online시 복구하라고 메세지 나옴

```sql
alter tablespace users offline immediate;
```

## 시점정보(체크포인트) 확인 쿼리

```sql
# 체크포인트 확인 쿼리
select a.file#
     , a.name
     , a.ts#
     , b.name
     , a.status
     , a.checkpoint_change#
  from v$datafile a
     , v$tablespace b
 where a.ts# = b.ts#;
```

