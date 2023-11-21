관계형 데이터베이스에서 사용하는 대부분의 색인은 btree+ 알고리즘 구현체다. 
이 btree+  색인의 한계가 자료가 많고, update, delete 작업이 빈번한 경우에 성능이 insert 전용으로 만들어진 색인보다 좋지 않다 - 빠르지 않다는 것이다.

원론적으로 트리구조에서 leaf간 이동이 많아지면, 많은 비용이 발생한다.



`CONCURRENTLY`(=범용적으론 ONLINE REINDEX)옵션을 제공해준다면
REINDEX에 부담을 가질 필요는 없다.

