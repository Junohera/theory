**클라우드 환경**

클라우드 환경이 대세고, 백업과 복구는 클라우드 서비스 제공자가 알아서 다 해주는 세상에 이 글을 길게 쓰는 것이 의미가 있는지는 모르겠지만, 여전히 온프레미스 방식의 레거시한 환경에서 업무를 하게되면 필요하고
클라우드 환경이더라도 드물게 수동으로 해야할 경우도 있기 때문에
DBA관점에서 하지 않길 바라지만 언제든 할 수 있는 상태가 되어있어야 한다.

**솔루션 활용** 

DBA는 솔루션을 선택하고 사용할 수 있다.
하지만 현 상황의 데이터베이스와 서버환경과
버전과 여러 사항을 고려하여 선택하고
검증도 할 수 있어야 한다.



1. fullbackup = basebackup
2. archive backup = transaction statements...

그렇다면 basebackup의 주기는 어떻게 결정 ?

archive 백업의 크기를 보고 결정
만약, 매월초에 풀백업했을 때, 월말에 복구해야하는 상황이 생겼을 때
평균 일별 archive size * 30을 대상으로 instance recovery(=archive replay)시 소요시간이 3일...
등의 상황을 고려하여 결정
그렇다고 매일 풀백업을 할 경우 저장공간의 제약이 발생하고
서비스의 유형에 따라 결정



일반적인 절차

- is server node for recovery ?
- is fullbackup files ?
- is completion backup ?
- is all archive files ?

이 중에 하나라도 어긋나지 않도록 평소에 관리를 해야한다.
