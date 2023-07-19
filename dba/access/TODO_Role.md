# Role

TODO: 20230527



## 방식

### 재접속 필요

|              | 재접속 필요여부 |
| ------------ | --------------- |
| 직접권한부여 | ❌               |
| 간접권한부여 | ✅               |

### 1. 직접 권한 부여(Permission)

```sql
grant create any table to scott;
grant select on scott.emp to itwill;
```

### 2. 간접 권한 부여(Role)

```sql
create role my_role1;
grant select on scott.emp to my_role1;
grant insert, update, delete on scott.emp to my_role1;
grant my_role1 to itwill;

-- 권한을 통한 권한부여이므로 반드시 재접속 안내 필수✅
```

