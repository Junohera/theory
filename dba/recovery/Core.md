[toc]

## using backup controlfile

**case**

1. old controlfile
2. generated controlfile(cause lost)

```sql
recover database until cancel using backup controlfile;
recover database until time '2023/07/24 00:00:0' using backup controlfile;
```

