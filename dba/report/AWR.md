[toc]

# Automatic Workload Repository

- oracle에서 제공하는 성능 진단 툴
- 성능결과를 파일 형태로 받아볼 수 있음
- DBMS 설치시 자동 동작(default: 8일동안의 snapshot 보관)



## management

### 1. check snapshot

```sql
select *
  from dba_hist_snapshot;
```

### 2. snapshot interval

```sql
select dbid,
			 snap_interval,		-- snapshot 주기(default: 1시간마다)
			 retention				-- 보관 주기(default: 8일)
	from dba_hist_wr_control;
	
|DBID         |SNAP_INTERVAL|RETENTION|
|-------------|-------------|---------|
|1,736,492,581|0 1:0:0.0    |8 0:0:0.0|
```

### 3. awr report 생성

헬스체크하기 위한 기간의 시작지점과 끝지점 사이에는
DB shutdown된 적이 없어야한다.
DB가 계속 open상태여야 성능뷰(dynamic performance view)를 통해 수집

```shell
cd $ORACLE_HOME/rdbms/admin
pwd
/oracle12/app/oracle/product/12.2.0.1/db_1/rdbms/admin
ll awrrpt*
-rw-r--r--. 1 oracle oinstall 9963 Aug 11  2016 awrrpti.sql		-- when RAC DB(node 선택 가능)✨
-rw-r--r--. 1 oracle oinstall 7857 Aug 11  2016 awrrpt.sql		-- when SINGLE DB✨

SQL> @?/rdbms/admin/awrrpt.sql

Enter value for report_type: html(default)
Enter value for num_days: 
Enter value for begin_snap: 
Enter value for end_snap: 

💥 shutdown했던 기록이 있을 경우 조회 불가
ERROR at line 1:
ORA-20200: The instance was shutdown between snapshots 21 and 68
ORA-06512: at line 46
✅ 
Enter value for report_name: 

SQL> exit
ls -rtl | tail -1
-rw-r--r--. 1 oracle oinstall 803176 Aug  4 14:51 awrrpt_1_61_68.html
```

![image-20230804145637695](C:\Users\ITWILL\AppData\Roaming\Typora\typora-user-images\image-20230804145637695.png)

<img src="C:\Users\ITWILL\AppData\Roaming\Typora\typora-user-images\image-20230804145557798.png" alt="image-20230804145557798" style="zoom:33%;" />