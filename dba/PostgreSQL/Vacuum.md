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

### 나이

> dba라면 database와 table의 나이를 항상 체크해야한다.
> 왜나하면 락을 걸게되는 작업 중
> 우선순위가 가장 높은 `to prevent wraparound`가 발생하기 때문이다.
>
> pgsql 입장에서는 `사용자를 다 죽이거나 다 대기시키더라도 지금 당장 이 작업을 해야해!!!`

**to prevent wraparound**

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
(더 정확히는 materialize view와 table 중 가장 많은 나이가 해당 데이터베이스의 나이)



### dead tuple 정리

평범한 서비스(게시판, ...)는 autovacuum의 파라미터를 손댈 일이 거의 없으나
대표적으로 ito 같은 서비스에 활용될 경우, 파라미터 설정을 해야할 수도 있고
더불어 테이블별, 데이터베이스별 설정도 가능하다.

dead tuple과 live tuple을 완벽히 정리해주는 vacuum full,
autovacuum이 해주지 않는다. (해당 작업이면 pg_repack도 있다. oracle reorg와 비슷)
 dml을 허용하면서(=table exclusive lock없이) 정리하는 것이 `pg_repack`

물론 pg_repack 또한 트레이드오프가 존재하는데, 이것에 대해 알아보고
직접 확인해보며 체득 후 하도록...



간단한 default도 없고, set not null도 없는 `add column`일 경우에
일반적으로는 바로 실행되지만, to prevent wraparound 프로세스가 떠있는 경우
엄청나게 오래 걸리므로 to prevent wraparound를 죽이고 add column하도록 하는 것이 맞지만
몇초이상 기다릴 경우, fail over 까지 간다.

---

1. vacuum full을 테이블을 잠그지 않고 실행하는 법 고민 필요
