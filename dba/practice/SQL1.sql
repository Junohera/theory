select name, value
  from v$parameter
 where name in ('shared_pool_size',		-- 0���� ��ȸ(���� ������ ���� ����)
                'sga_target',			-- ASMM ���� ������(0�̸� �̻��, 0�̻��̸� ���)
                'memory_target');		-- AMM ���� ������(0�̸� �̻��, 0�̻��̸� ���)
                
select pool,
       round(sum(bytes)/1024/1024, 2) as "size(MB)"
  from v$sgastat
 group by pool;
 
select round((1 - sum(reloads)/sum(pins)) * 100, 2) "Library Cache Hit Ratio"
  from v$librarycache;
  
SELECT (1-SUM(getmisses)/SUM(gets))*100 "Data Dictionary Hit Ratio"
  FROM V$ROWCACHE;