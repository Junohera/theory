[toc]

# Recovery

<img src="./assets/Recovery.png" alt="Recovery" style="zoom:50%;" />

## Database Recovery

### offline fullbackup restore / recover

DB shutdown 후, 모든 file(control, redo, datafile)을 백업했다면
이 모든 파일들이 시점 일치하므로 restore 후 바로 open 가능

만약 장애 복구시

offline 백업본 중, controlfile을 restore하면 복구시점을 controlfile이 가지므로 현재 시점까지 복구 진행 불가
=> 불완전 복구 시도시 controlfile은 restore 대상이 아님

### datafile restore / recover

현재 control, redolog file은 마지막 시점을 알고 있는 상태, 
원하는 시점으로의 복구를 위해 아카이브 적용 목적이라면 controlfile 기준에서 logfile을 믿지않을 경우, archive파일을 적용할
✅**datafile만 restore** 진행,
	datafile이 갖는 scn과 controlfile이 갖는 scn의 차이만큼 복구 진행

	1) until cancel : 사용자가 cancel하거나, 계속 아카이브를 적용하다 더 이상 불가능한 상태 직전까지의 복구를 목적
	1) until time: 복구 시점을 정확히 알 때

## incomplete recovery

### until cancel

- 물리적인 파일의 손상발생했을 경우
- 정확한 내역을 알고 있을 경우

### until time

- 논리적인 손상일 경우(ex: truncate, delete ...)
- 복구시점을 정확히 알고 있을 경우

## 리커버리 관점 파일별 대응

### controlfile

- 없다면 재생성
  ```sql
  startup nomount;
  @control
  ```

  

### datafile

- 없다면 archive file로 대체

### redologfile

- 없거나 문제발생시
  - drop
  - clear
  - resetlogs