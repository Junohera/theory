[toc]



### manual

```sql
\?
```



#### gexec

> 쿼리를 제너레이션한 쿼리를 실행하는 방법

```sql
postgres=# select 'select 1 + 1;';\gexec
   ?column?    
---------------
 select 1 + 1;
(1 row)

 ?column? 
----------
        2
(1 row)
```

