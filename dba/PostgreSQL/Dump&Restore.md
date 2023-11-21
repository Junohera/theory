1. pg_dump
2. pg_restore

위의 절차를 가질 경우 `-Fc`옵션을 권장.
왜냐하면 pg_dump 에서 -F 옵션 없이 그냥 일반 SQL 구문으로 덤프 받은 파일은 psql 명령으로 작업한다

---

dba는 dump할일이 거의 없다.
엄밀하게 백업과는 다르므로 

