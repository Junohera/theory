[toc]

# Oracle Instance Life Cycle

## Startup

`startup [step]`

### 1. nomount

### 2. mount

### 3. open(default)

## Shutdown

`shutdown [option]`

### immediate

> dirty buffer의 내용을 수행 및 완료 후 종료

사용자의 작업을 강제로 종료

메모리의 데이터를 **디스크에 저장하고 안전하게 종료**

commit 되지않은 세션 데이터는 rollback

commit된 데이터는 DB에 내려 쓰는 작업을 완료한 후 DB 종료

### abort

> dirty buffer의 내용을 수행하지 않고 종료

메모리(db buffer cache)의 데이터를 **디스크에 저장하지 않고 즉시 종료**

DB 기동시 아직 정리되지 않은 메모리 영역을 디스크에 저장하는 instance recovery를 수행(SMON[^SMON])

redo log buffer의 내용은 DB가 내려가기 전 안전하게 redo log file에 내려써짐(LGWR[^LGWR])



