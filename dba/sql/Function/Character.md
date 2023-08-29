[toc]

# Character Functions

## Case substitution

- upper
- lower
- initcap

```sql
select 'abcd',
       upper('abcd'),
       lower('abcd'),
       initcap('abcd')
  from dual;
```

## Length

- length
- lengthb

```sql
select 'abcd',
			 length('abcd'),
			 lengthb('abcd')
  from dual;
```

## Extracting

- `substr(target, position, [count])`

- `substrb(target, position, [count])`

  > 1. 개수의 기본값은 전부이므로, 생략시 마지막까지 추출
  > 2. 추출위치는 음수가 될 수 있음(뒤에서부터 추출, 정방향 추출)
  > 3. 리턴되는 데이터 타입은 항상 문자(입력은 문자가 아니어도 가능)

```sql
select 'abcde',
       substr('abcde', 1, 1),   substrb('abcde', 1, 1), 
       substr('abcde', 1),      substrb('abcde', 1), 
       substr('abcde', 2, 1),   substrb('abcde', 2, 1), 
       substr('abcde', 2),      substrb('abcde', 2), 
       substr('abcde', 3, 1),   substrb('abcde', 3, 1), 
       substr('abcde', 3),      substrb('abcde', 3), 
       substr('abcde', 4, 1),   substrb('abcde', 4, 1), 
       substr('abcde', 4),      substrb('abcde', 4), 
       substr('abcde', 5, 1),   substrb('abcde', 5, 1), 
       substr('abcde', 5),      substrb('abcde', 5), 
       substr('abcde', 6, 1),   substrb('abcde', 6, 1), 
       substr('abcde', 6),      substrb('abcde', 6), 
       substr('abcde', -2),     substrb('abcde', -2), 
       substr('abcde', -2, 2),  substrb('abcde', -2, 2) 
  from dual;
```

## position

- `instr(target, keyword, start, count)`

  > 1. 시작위치의 기본값은 1이므로 생략시 처음부터 확인
  > 2. 발견횟수의 기본값은 1이므로 생략시 가장 처음 발견되는 문자열의 위치를 반환
  > 3. 시작 위치는 음수 가능하고, 역방향 탐색이며 주의할 점은 발견횟수의 방향도 역방향으로 변경
  > 4. 만약, 찾은 결과가 없다면 -1이 아닌 0을 리턴

```sql
select 'a@b@c@',
       instr('a@b@c@', '@'),
       instr('a@b@c@', '@', 1, 1),
       instr('a@b@c@', '@', 1, 2),
       instr('a@b@c@', '@', 3, 1),

       instr('a@b@c@', '@', -4, 1),
       instr('a@b@c@', '@', -4, 2),
       instr('a@b@c@', '@', -4, 3),
       instr('a@b@c@', '@', -1, 1),
       instr('a@b@c@', '@', -1, 2),
       instr('a@b@c@', '@', -1, 3)

  from dual;
```

## Substitution 

- replace
- translate

> 1. replace 호출시 바꿀 문자열을 지정하지 않으면, 찾을 문자열이 삭제되므로, 결과적으로 삭제행위가 필요할 때 사용하기도 함.
> 2. translate는 바꿀 문자열의 생략이 불가능하여 삭제가 불가능하지만
>    허수를 사용할 경우 삭제행위를 의도할 수 있다.
>    반대로 "찾을 문자열"과 "바꿀 문자열"의 갯수가 일치하지 않을 경우 부족한 길이만큼 빈문자열로 취급되기 때문에 삭제를 유발할 수도 있다.
>    a) "찾을 문자열"의 길이 > "바꿀 문자열"의 길이 => 삭제(짝이 없는 글자)
>    b) "찾을 문자열"의 길이 > "바꿀 문자열"의 길이 => 무시(짝이 없는 글자)

```sql
select str,
       replace(str, 'ab', 'AB') as replace_1,
       replace(str, 'ab', '') as replace_2,
       replace(str, 'ab', 'A') as replace_3,
       translate(str, 'ab', 'AB') as translate_1,
       translate(str, 'ab', '') as translate_2,
       translate(str, 'ab', 'A') as translate_3
  from (select 'abcba' as str
          from dual);
|STR  |REPLACE_1|REPLACE_2|REPLACE_3|TRANSLATE_1|TRANSLATE_2|TRANSLATE_3|
|-----|---------|---------|---------|-----------|-----------|-----------|
|abcba|ABcba    |cba      |Acba     |ABcBA      |           |AcA        |
```

**주민번호 마스킹 처리**

```sql
select name,
       jumin,
       substr(jumin, 1, 6) || 'XXXXXXX' as "mask(simplify)",
       substr(jumin, 1, 6) || translate(substr(jumin, 7), '0123456789', 'XXXXXXXXXX') as "mask(correctly)"
  from student;
```

## Padding

- `rpad(target, length, pad)`
- `lpad(target, length, pad)`

> 1. 자릿수는 삽입문자열을 삽입하여 만드는 문자열 총 자릿수 의미
> 2. length(대상) < length(자릿수)
> 3. 삽입 문자열은 공백이 기본값

```sql
select lpad(str, 5, '*'),
       rpad(str, 5, '*'),
       lpad(str, 5),
       rpad(str, 5)
  from (select 'abcd' as str
          from dual);  
```

## Trim

- `trim(target, [another character])`
- `ltrim(target, [another character])`
- `rtim(target, [another character])`

> 삭제문자열의 기본값은 공백
>
> trim은 하나의 인수만 전달 가능 => 양방향이며 공백만 삭제 가능

```sql
select 'aaabcadaaa',
       ltrim('aaabcadaaa', 'a'),
       rtrim('aaabcadaaa', 'a'),
       ltrim('  aa  '),
       length(ltrim('  aa  ')),
       length(trim('  aa  '))
  from dual;
```

