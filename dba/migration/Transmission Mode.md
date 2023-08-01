[toc]

# Transmission Mode

|                  | Conventional | Direct |
| ---------------- | ------------ | ------ |
| velocity         | ⬇            | ⬆      |
| logging(redolog) |              | ❌      |
| need backup      |              | ⭕      |



## Conventional Mode

일반 insert처럼 한건씩 처리하는 방식

## Direct Mode

대용량 데이터 적재를 빠르게 처리하기 위한 적재 방식

데이터 버퍼 캐시를 사용하지 않고, 디스크에 직접 기록

redo buffer의 사용을 최소하면서 데이터 적재

대신 복구시 문제가 될 수 있으므로 백업을 수행하는게 사실상 필수