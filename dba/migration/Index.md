[toc]
# Migration

## as a file

> easy, worst performance 
```sql
💙 BLUE
Tools > Unload Tool
scott.student

💚 GREEN
Tools > Load Tool
truncate table scott.student;
select * from scott.student;
no rows selected.

import data scott.student;
```

## as a command

> complex, better performance

```sql
sqlldr userid/password control=controlfile [log=logfile] [bad=badfile] [options]
```

- control file: ref data loading preference
- log file: result
- bad file: if fail

### control file

```shell
vi control_student.ctl

load data
infile '/home/oracle/student.csv'
into table student
fields terminated by ','
(STUDNO,NAME,ID,GRADE,JUMIN,BIRTHDAY,TEL,HEIGHT,WEIGHT,DEPTNO1,DEPTNO2,PROFNO)
```

```shell
sqlldr scott/oracle control=control_student.ctl
```

---

## Options

- append | replace | truncate

- fields terminated by ','

- optionally enclosed by '"'

- terminated by whitespace: 마지막 컬럼 인식오류
  ```shell
  (a
  ,b
  ,${COLUMN_NAME} terminated by whitespace)
  ```

## practice

### basic

```shell
SQL> create table scott.sqlldr_test1(no number, name varchar2(16));

mkdir -p /home/oracle/sqlldr
cd /home/oracle/sqlldr

vi test1.csv
1,a
2,b
3,c
4,d
:wq

vi control_test1.ctl
infile '/home/oracle/sqlldr/test1.csv'
into table sqlldr_test1
fields terminated by ','
(no, name)
:wq

sqlldr scott/oracle control=control_test1.ctl

SQL> select * from scott.sqlldr_test1;
        NO NAME
---------- ----------------
         1 a
         2 b
         3 c
         4 d
```

### when column names in head

```shell
SQL> create table scott.sqlldr_test2(no number, name varchar2(16));

mkdir -p /home/oracle/sqlldr
cd /home/oracle/sqlldr

vi test2.csv
no,name💥
1,a
2,b
3,c
4,d
:wq

vi control_test2.ctl
options(skip=1)✅
load data
infile '/home/oracle/sqlldr/test2.csv'
into table sqlldr_test2
fields terminated by ','
(no, name)
:wq

sqlldr scott/oracle control=control_test2.ctl

SQL> select * from scott.sqlldr_test2;

        NO NAME
---------- ----------------
         1 a
         2 b
         3 c
         4 d
```

### when include data at controlfile

```shell
SQL> create table scott.sqlldr_test3(no number, name varchar2(16));

mkdir -p /home/oracle/sqlldr
cd /home/oracle/sqlldr

vi control_test3.ctl
load data
infile *
replace
into table sqlldr_test3
fields terminated by ','
(no, name)
begindata
11,a
22,b
33,c
44,d

sqlldr scott/oracle control=control_test3.ctl
SQL> select * from scott.sqlldr_test3;

        NO NAME
---------- ----------------
        11 a
        22 b
        33 c
        44 d
```

### when with quotation

```shell
SQL> create table scott.sqlldr_test4(no number, name varchar2(16));

mkdir -p /home/oracle/sqlldr
cd /home/oracle/sqlldr

vi control_test4.ctl
load data
infile *
into table sqlldr_test4
fields terminated by ','
optionally enclosed by '"'
(no, name)
begindata
11,"a"
22,"b"
33,"c"
44,"d"

sqlldr scott/oracle control=control_test4.ctl
SQL> select * from scott.sqlldr_test4;

        NO NAME
---------- ----------------
        11 a
        22 b
        33 c
        44 d
```

### when field delimiters are unclear(direct position)

```shell
export NLS_LANG=KOREAN_KOREA.AL32UTF8
SQL> create table scott.sqlldr_test5(no number, last_name varchar2(8), position varchar2(16), sal number, comm number, deptno number);

mkdir -p /home/oracle/sqlldr
cd /home/oracle/sqlldr

vi test5.prn
1000 choi 사장 1000  0 10
1001 yoon 상무  700 10 20
1002 hong 과장 1000 50 30
:wq

vi control_test5.ctl
load data
characterset utf8
infile '/home/oracle/sqlldr/test5.prn'
into table sqlldr_test5
trailing nullcols
(no position(01:04) integer external
,last_name position(6:9) char
,position position(11:16) char
,sal position(18:21) integer external
,comm position(23:24) integer external
,deptno position(26:27) integer external)

sqlldr scott/oracle control=control_test5.ctl
SQL> select * from scott.sqlldr_test5;

        NO LAST_NAM POSITION                SAL       COMM     DEPTNO
---------- -------- ---------------- ---------- ---------- ----------
      1000 choi     사장                   1000          0         10
      1001 yoon     상무                    700         10         20
      1002 hong     과장                   1000         50         30
```

### student.csv

```shell
export NLS_LANG=KOREAN_KOREA.AL32UTF8
mkdir -p /home/oracle/sqlldr
cd /home/oracle/sqlldr

cat student.csv | head -5
STUDNO,NAME,ID,GRADE,JUMIN,BIRTHDAY,TEL,HEIGHT,WEIGHT,DEPTNO1,DEPTNO2,PROFNO
9411,▒▒▒▒▒,75true,4,7510231901813,1975/10/23 00:00:00,055)381-2158,180,72,101,201,1001
9412,▒▒▒▒▒,pooh94,4,7502241128467,1975/02/24 00:00:00,051)426-1700,172,64,102,,2001
9413,▒̹̰▒,angel000,4,7506152123648,1975/06/15 00:00:00,053)266-8947,168,52,103,203,3002
9414,▒▒▒▒▒,gunmandu,4,7512251063421,1975/12/25 00:00:00,02)6255-9875,177,83,201,,4001

iconv -c -f euc-kr -t UTF-8 student.csv --output student.csv

cat student.csv | head -5
STUDNO,NAME,ID,GRADE,JUMIN,BIRTHDAY,TEL,HEIGHT,WEIGHT,DEPTNO1,DEPTNO2,PROFNO
9411,서진수,75true,4,7510231901813,1975/10/23 00:00:00,055)381-2158,180,72,101,201,1001
9412,서재수,pooh94,4,7502241128467,1975/02/24 00:00:00,051)426-1700,172,64,102,,2001
9413,이미경,angel000,4,7506152123648,1975/06/15 00:00:00,053)266-8947,168,52,103,203,3002
9414,김재수,gunmandu,4,7512251063421,1975/12/25 00:00:00,02)6255-9875,177,83,201,,4001

vi control_student.ctl
options(skip=1)
load data
infile 'student.csv'
append
into table student
fields terminated by ','
trailing nullcols
(STUDNO,NAME,ID,GRADE,JUMIN,BIRTHDAY,TEL,HEIGHT,WEIGHT,DEPTNO1,DEPTNO2,PROFNO terminated by whitespace)
:wq

sqlldr scott/oracle control=control_student.ctl

SQL> select * from scott.student;

💥 레코드 3: 거부됨 - STUDENT 테이블, PROFNO 열에 오류가 있습니다.
논리 레코드가 종료하기 전에 열을 찾지 못했습니다 (TRAILING NULLCOLS 사용)
💊 trailing nullcols

💥 레코드 19: 거부됨 - STUDENT 테이블, BIRTHDAY 열에 오류가 있습니다.
ORA-01861: 리터럴이 형식 문자열과 일치하지 않음
💊 alter table scott.student modify birthday varchar2(32);

💥 레코드 12: 거부됨 - STUDENT 테이블, JUMIN 열에 오류가 있습니다.
ORA-12899: "SCOTT"."STUDENT"."JUMIN" 열에 대한 값이 너무 큼(실제: 19, 최대값: 13)
💊 alter table scott.student modify jumin varchar2(32);

💥 레코드 1: 거부됨 - STUDENT 테이블, PROFNO 열에 오류가 있습니다.
ORA-01722: 수치가 부적합합니다
💊 PROFNO terminated by whitespace)

sqlldr scott/oracle control=control_student.ctl

SQL*Loader: Release 12.2.0.1.0 - Production on 월 7월 31 12:30:21 2023

Copyright (c) 1982, 2017, Oracle and/or its affiliates.  All rights reserved.

사용된 경로:      규약
커밋 시점에 도달 - 논리 레코드 개수 20
테이블 STUDENT:
  20 행이(가) 성공적으로 로드되었습니다.

SQL> select studno, name, id, grade from scott.student;
    STUDNO NAME                 ID                                  GRADE
---------- -------------------- ------------------------------ ----------
      9411 서진수               75true                                  4
      9412 서재수               pooh94                                  4
      9413 이미경               angel000                                4
      9414 김재수               gunmandu                                4
      9415 박동호               pincle1                                 4
      9511 김신영               bingo                                   3
      9512 신은경               jjang1                                  3
      9513 오나라               nara5                                   3
      9514 구유미               guyume                                  3
      9515 임세현               shyun1                                  3
      9611 일지매               onejimae                                2
      9612 김진욱               samjang7                                2
      9613 안광훈               nonnon1                                 2
      9614 김문호               munho                                   2
      9615 노정호               star123                                 2
      9711 이윤나               prettygirl                              1
      9712 안은수               silverwt                                1
      9713 인영민               youngmin                                1
      9714 김주현               kimjh                                   1
      9715 허우                 wooya2702                               1
```

```sql
alter session enable parallel ddl;
alter session enable parallel dml;


-- 1. CTAS로 이동
create table scott.student_backup
parallel 8
as
select /*+ parallel(s 8) */ *
  from scott.student s;

-- 2. null로 변경 4 데이터타입 변경
update /*+ parallel(s 8) */ scott.student s
   set birthday = null;
commit;

-- 3. 데이터타입 변경
alter table scott.student modify birthday date;

-- 4. 변경된 타입으로 복원
update /*+ parallel(s1 8) */ scott.student s1
   set birthday = (select /*+ parallel(s2 8) */ to_date(birthday, 'YYYY/MM/DD HH24:MI:SS') 
                     from scott.student_backup s2
                    where s1.studno = s2.studno);
commit;

-- 5. 확인 및 불필요 테이블 삭제
select * from scott.student;
drop table scott.student_backup purge;
```

