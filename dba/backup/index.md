[toc]

# Backup

## 1. Target

- parameter file
- DB files(control/redo/data**)
- archive log file
- backup controlfile

### require

1. data file
2. parameter file

## 2. Period

- 업무 중요도
- storage 사용량
- 복구 수행 시간
- ...

## 3. Method

### cold - offline

가장 안전하고 확실하게 백업받는 방법

offline fullbackup본을 사용하여 과거 시점으로의 DB open 가능

### hot - online

- tablespace 단위
- begin backup으로 백업 시점 확보(DBWR에 의해 시점정보가 해당 tablespace가 기록)
- begin backup을 했을 때, 체크포인트가 발생되어 버퍼에 쌓인 내용을 파일에 내려쓰고,
  이후에 들어온 DML들은 메모리에 유지되고, end backup을 통해 다시 원상복구되어진다.
- hot backup 흐름
  1. begin backup 
  2. physical cp
  3. end backup