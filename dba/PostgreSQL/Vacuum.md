autovacuum이 되지 않는 이유

1. worker 할당 수 미달
2. ratio 임계치 미달



vacuum과 vacuum full의 차이
lock 상태로 돌입시 exclusive lock의 타입이 다르다
(dml 허용/비허용)



tip

vacuum full은 내부적으로 테이블을 새로만드는 작업이 포함되므로
업무시간에 하는 것은 원칙적으로 하면 안된다.



vacuum full을 하기전에
vacuum을 통해 fsm, vm을 최신화 하고
vacuum full을 하는 것이 꼼수이지만, 

---

### to prevent wraparound

> aurora든 뭐든 pgsql을 사용한다면 항상 마주치게되므로
> 원인과 대처 방법을 머릿속에 정리해두어야한다.

일반적인 vacuum으로 받아들이면 안된다.
wraparound로 인해 발생하는 것

wraparound란 ? 
new와 old를 보장해주기 위해 42억 중 1/2인 21억개만 사용이 가능
이 때, old에 대해서는 시계방향과 상관없이 영구보관하기 위해 프리징 상태로 변경

txid 겹침현상을 방지하기 하는 메커니즘으로 인해
발생하는 현상

나이: old txid와 new txid의 차이
나이가 2억살이 넘어갈 경우, autovacuum을 통해 old txid들을 영구보관하고,
나이를 다시 0살로 만든다.(환생 ??)

단, 나이는 database와 table이 별개로 관리되어지고,
database의 나이는 모든 table 중, 가장 오래된 txid를 기준으로 하기 때문에
database의 나이를 0으로 만드려면, 가장 오래된 테이블들을 순회하며 vacuum해야한다.



평범한 서비스(게시판, ...)는 autovacuum의 파라미터를 손댈 일이 거의 없으나
대표적으로 ito 같은 서비스에 활용될 경우, 파라미터 설정을 해야할 수도 있고
더불어 테이블별, 데이터베이스별 설정도 가능하다.