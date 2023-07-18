[toc]

# Profile

> - user와 관련된 정책
> - user 생성시 지정 가능(생략시 default profile로 지정)

## Properties

#### **Failed_login_attemps**

login 시도 실패횟수 지정. 이 횟수 만큼 틀리면 잠김 

### **Password_lock_time**

계정 lock 되는 일수 지정 

### **Password_life_time**

패스워드 유효기간 

### **Password_grace_time**

암호를 변경할 수 있는 추가 기간 지정

### **Password_reuse_time**

암호 변경 시 같은 암호로 변경 못하게 막는 일수 지정

### **Password_reuse_max**

동일 암호를 최대 사용할 수 있는 횟수 지정

### **Password_verify_function**

암호를 복잡하게 만들 함수를 사용

## Manage

### select

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



