[toc]

## listener.ora

> 리스너 서비스 관련 파일

```shell
lsnrctl status
lsnrctl start
lsnrctl status
ps -ef | grep lsnr | grep -v grep # pslsnr
```

### 위치

```shell
cd $ORACLE_HOME;find . -name listener.ora -type f;
```

### 실행 조건

- 리스너 서비스명과 일치하는 DB Open
- host 충돌
- port 충돌

