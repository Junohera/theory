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
  
select name,
			 value,
			 display_value
  from v$parameter
 where name in ('db_cache_size',
                'sga_target',
                'memory_targert');
                
select *
  from v$sga_dynamic_components;
  
select sum(current_size)/1024/1024 "DB Buffer Cache(MB)"
  from v$sga_dynamic_components
 where component like '%buffer cache%';
 
select round(((1-(sum(decode(name, 'physical reads', value, 0))
	     / (sum(decode(name, 'db block gets', value, 0))													--logical read중 일부 
	     + (sum(decode(name, 'consistent gets', value, 0)))))) * 100), 2)					--logical read중 일부 
	     as "Buffer Cache Hit Ratio"
	from v$sysstat;
    
select name,
		   value,
		   display_value
	from v$parameter
 where name = 'log_buffer';
 
select *
	from v$parameter
 where name = 'log_buffer';
 
select name,
			 value,
			 default_value
  from v$parameter
 where name in ('large_pool_size',
                'java_pool_size',
                'streams_pool_size');