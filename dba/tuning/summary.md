index scan또한 index block을 탐색하는 행위를 수반하기에 index scan이 항상 유리한건아니다.
가령 특정테이블의 90%에 해당하는 데이터를 찾을 경우, 처음부터 full table scan이 더 유리할 수도 있다.

통계정보가 없을경우
분포 비율을 distinct value별로 골고루 가져가므로, 
ex) 특정 컬럼에 데이터 분포가 90:10임에도, 통계정보가 없는 상태에서 인덱스 스캔을 할 경우
50:50으로 진행되어 의도와 다른 결과가 나타남.

1. hint 강제
2. 통계 정보 갱신
	2-1. import
	2-2. warm up

target
	- self
	- Top query
		- Automatic Workload Repository
planning

tuning
	logical
		index
		hint /*+ INDEX_ASC(tbs1 index1) */
		update analysis
		sql
		modeling
		partition
	physical
		storage
			reorg
validation
apply