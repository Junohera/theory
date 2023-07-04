### RAC

**R**eal **A**pplication **C**lusters

> = cluster
> = Grid

### DBMS

Memory + Disk

> single instance => 1 memory

### SID

**S**ervice **I**dentifier

### Schema

User's space, Object

### External Execute Query

1. enter: `sqlplus ${USER}/${PASSWORD}`
2. feedback off: `set feedback off;`
3. run: `@${FILENAME}.sql`

#### Set Date Format 

```sql
alter session set nls_date_format = 'YYYY/MM/DD';
alter session set nls_date_language = 'american';
```

### PGA

> **P**rogram **G**lobal **A**rea
> **P**rivate **G**lobal **A**rea

### ANSI

>  **A**merican **N**ational **S**tandards **I**nstitute

### Sub query

**by position**

- Scala
- Inline View
- General

**by form**

- Single row
- Multiple row
- Multiple column
- Correlated 