[toc]

# Directive

## if

```sql
begin
  if condition1 then return1; end if;
  if condition2 then return2; end if;
  if condition3 then return3; end if;
end;
/
```

```sql
begin
  if condition1 then
    -- do anything
  else
    -- do anything
  end if;
end;
/
```

```sql
begin
  if condition1 then
    -- do anything
  elsif condition2 then
    -- do anything
  else
    -- do anything
  end if;
end;
/
```

## case

```sql
begin
  select ... into val1
    from ...;
    
  var2 := case when var1 > 1000 then 'A'
               when ...         then 'B'
                                else 'C' end;
end;
/
```

## loop

### loop

반복 대상이 정해져있지 않음
exit으로 반복 종료 정의 필요

```sql
begin
  loop
    -- do anything
    exit when condition;
  end loop;
end;
/
```

### for

반복횟수, 대상이 정해져 있는 경우의 반복처리
반복 종료 기점 명확

```sql
begin
  for $VAR in $TARGET loop
    -- do anything
  end loop;
end;
/
```

### while

반복을 수행할 조건이 정해져있는 경우, 반복처리

```sql
begin
  while condition loop
    -- do anything
  end loop;
end;
/
```

