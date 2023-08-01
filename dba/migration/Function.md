# Function

> 함수를 몰랐을 때에는 
> 한쪽 엔드포인트에 데이터타입을 받아주는식으로 별도 처리를 하다보니 컬럼의 데이터타입까지 건들게 되었지만,
>
> 함수를 사용하게 될 경우, 전달하면서 목적지의 데이터타입에 맞추어 변형이 가능하여 목적지의 변형없이 데이터 전달이 가능함.

## flow

1. 데이터 서버 전달(student.csv)

2. encoding

3. create controlfile
   ```shell
   vi student.ctl
   options (skip=1)
   load data
   characterset utf8
   infile "student.csv"
   into table student
   fields terminated by ','
   (studno,
   name,
   id,
   grade,
   jumin,
   birthday "to_date(:birthday, 'YYYY/MM/DD HH24:MI:SS')",
   tel,
   height,
   weight,
   deptno1,
   deptno2,
   profno terminated by whitespace)
   ```

4. 데이터 적재

```shell
SQL> truncate table scott.student;

sqlldr scott/oracle control=student.ctl

SQL> select count(*) from scott.student;
  COUNT(*)
----------
        20
```

