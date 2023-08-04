[toc]

# Procedure

## definition

```sql
create or replace procedure insert_job_test1
is
	begin
		insert into tab_job_test1
		values(seq_job_test1.nextval, dbms_random.string('A', 5));
		commit;
	end;
```

