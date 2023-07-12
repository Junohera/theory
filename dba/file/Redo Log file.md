# Redo Log File

> 변경되기 전의 내용과 변경된 후의 내용을 기록하는 파일

## 특징

- 오라클 서버는 데이터가 변경될 경우 장애를 대비해 변경되기 전의 내용과 변경된 후의 내용을 기록해둔다 
- 기록되는 장소 중 메모리는 Redo Log Buffer
- 기록되는 장소 중 파일은 Redo Log File

## 구성

- Redo Log File은 그룹과 멤버라는 개념으로 관리
- 최소 그룹의 개수는 2개이며, 그룹별로 필요한 최소 Member 수는 1 개
- 같은 그룹의 Member는 같은 내용 저장
- Member를 많이 추가하면 안정적일 수는 있지만, 기록시간이 증가하면서 부하를 줄 수 있음
- 같은 그룹의 멤버는 서로 다른 디스크에 저장되는 것을 권장
- LGWR이 Redo Log Buffer -> Redo Log File 중에 가득차게 되면 **Log Switch가 발생** -> 라운드 로빈 방식으로 결정
- ✅**Redo Log File 크기가 너무 작을 경우 LOG SWITCH가 자주 발생하여 성능저하**가 될 수 있고, 너무 크면 데이터의 손상 가능성이 커지므로 적절하게 설정 필요
- ✅그룹에 멤버가 여러 개일 경우 병렬로 동시에 같은 내용을 기록하는데 멤버가 **같은 디스크에 존재한다면 직렬로 기록**하게 된다
- ✅Log Switch가 발생하게 되면 **Checkpoint 신호 발생**

## log 생성 원리

**Write Log Ahead**

- 데이터를 변경하기 전에 Redo Log에 먼저 기록 후 데이터를 변경( LGWR 작동 후 DBWR 작동) 

**Log Force at commit**

- 사용자로부터 Commit요청이 들어오면 관련된 모든 Redo Recode들을 redo Log file에 저장한 후 Commit 을 완료
- 대량의 데이터 변경 후 Commit이 한꺼번에 수행시 성능이슈



## Practice

# foot note

[^global checkpoint]: shutdown immediate시 발생, checkpoint는 가장 강력한 동기 신호
