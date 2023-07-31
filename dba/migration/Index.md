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

