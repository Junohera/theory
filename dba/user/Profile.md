[toc]

# Profile

> - user와 관련된 정책
> - user 생성시 지정 가능(생략시 default profile로 지정)

## Properties

### 1. password

| KEY                      | VALUE                                               |
| ------------------------ | --------------------------------------------------- |
| FAILED_LOGIN_ATTEMPTS    | LOGIN 시도 실패횟수 지정. 이 횟수 만큼 틀리면 잠김  |
| PASSWORD_LOCK_TIME       | 계정 **LOCK** 되는 일수 지정                        |
| PASSWORD_LIFE_TIME       | 패스워드 유효기간                                   |
| PASSWORD_GRACE_TIME      | 암호를 변경할 수 있는 추가 기간 지정                |
| PASSWORD_REUSE_TIME      | 암호 변경 시 같은 암호로 변경 못하게 막는 일수 지정 |
| PASSWORD_REUSE_MAX       | 동일 암호를 최대 사용할 수 있는 횟수 지정           |
| PASSWORD_VERIFY_FUNCTION | 암호를 복잡하게 만들 함수를 사용                    |

#### PASSWORD_VERIFY_FUNCTION

password verify function이름의 관리정책 제공
`default verify_function`에는 다음의 내용이 포함됨
`$ORACLE_HOME/rdbms/admin/utlpwdmg.sql`

1. isLessLen 4
2. isDiff id, password
3. isContain
   - least 1 Special
   - least 1 Alpla
   - least 1 Digit
4. isGreatherThanEqual
   - 3 diff Char at prev Password

### 2. resource

> resource limit이 true일 때만 적용

| KEY               | VALUE                                                        |
| ----------------- | ------------------------------------------------------------ |
| CPU_PER_SESSION   | 하나의 세션이 cpu를 연속적으로 사용할 수 있는 최대 시간 설정 |
| SESSIONS_PER_USER | 하나의 계정으로 동시접속 가능한 사용자 수                    |
| IDLE_TIME         | 유휴시간(세션 만료시간)                                      |

## Manage

### select

#### 1. profile

```sql
select *
  from dba_profiles;
  
select *
  from dba_profiles
 where 1=1
   and profile = 'DEFAULT'
   and resource_type = 'PASSWORD';
   
|PROFILE|RESOURCE_NAME           |RESOURCE_TYPE|LIMIT    |COMMON|INHERITED|IMPLICIT|
|-------|------------------------|-------------|---------|------|---------|--------|
|DEFAULT|FAILED_LOGIN_ATTEMPTS   |PASSWORD     |10       |NO    |NO       |NO      |
|DEFAULT|PASSWORD_LIFE_TIME      |PASSWORD     |180      |NO    |NO       |NO      |
|DEFAULT|PASSWORD_REUSE_TIME     |PASSWORD     |UNLIMITED|NO    |NO       |NO      |
|DEFAULT|PASSWORD_REUSE_MAX      |PASSWORD     |UNLIMITED|NO    |NO       |NO      |
|DEFAULT|PASSWORD_VERIFY_FUNCTION|PASSWORD     |NULL     |NO    |NO       |NO      |
|DEFAULT|PASSWORD_LOCK_TIME      |PASSWORD     |1        |NO    |NO       |NO      |
|DEFAULT|PASSWORD_GRACE_TIME     |PASSWORD     |7        |NO    |NO       |NO      |
|DEFAULT|INACTIVE_ACCOUNT_TIME   |PASSWORD     |UNLIMITED|NO    |NO       |NO      |
```

#### 2. user

```sql
select username,
       account_status,
       lock_date,
       expiry_date,
       default_tablespace,
       temporary_tablespace,
       profile
  from dba_users
 where 1=1
   and username = 'TUSER'
;
```

#### 3. resource limit

```sql
select * 
  from v$parameter 
 where name ='resource_limit';
```

### create

```sql
create profile profile1 limit
FAILED_LOGIN_ATTEMPTS 5
PASSWORD_LIFE_TIME 60
PASSWORD_VERIFY_FUNCTION verify_function;
```

### alter

#### 1. user

```sql
alter user tuser profile profile1;
```

#### 2. profile policy

```sql
alter profile ${PROFILE_NAME} limit ${POLICY_NAME} ${POLICY_VALUE};

alter profile default limit FAILED_LOGIN_ATTEMPS 5;
alter profile default limit PASSWORD_VERIFY_FUNCTION VERIFY_FUNCTION;
alter profile default limit PASSWORD_VERIFY_FUNCTION null;
```



