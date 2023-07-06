select name, value
  from v$parameter
 where name in ('shared_pool_size',		-- 0으로 조회(직접 설정한 값이 없음)
                'sga_target',			-- ASMM 사용시 설정값(0이면 미사용, 0이상이면 사용)
                'memory_target');		-- AMM 사용시 설정값(0이면 미사용, 0이상이면 사용)
                
select pool,
       round(sum(bytes)/1024/1024, 2) as "size(MB)"
  from v$sgastat
 group by pool;
 
select round((1 - sum(reloads)/sum(pins)) * 100, 2) "Library Cache Hit Ratio"
  from v$librarycache;
  
SELECT (1-SUM(getmisses)/SUM(gets))*100 "Data Dictionary Hit Ratio"
  FROM V$ROWCACHE;