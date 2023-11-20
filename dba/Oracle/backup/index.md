[toc]

# Backup

> when archive log mode = 'ON'

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

- **tablespace** 단위
- begin backup으로 백업 시점 확보(DBWR에 의해 시점정보가 해당 tablespace가 기록)
- **begin backup을 했을 때, 체크포인트가 발생**되고,
  이후의 DML들은 redo에 보관하고
  **end backup을 선언하는 순간 체크포인트 발생**한다.
- hot backup 흐름
  1. begin backup
  2. physical cp
  3. end backup

---

## 주의사항

💥 begin을 하지 않고,(=checkpoint 미발생) cp를 하게되면 파일 깨짐의 위험성이 존재(반드시 readonly를 만들고)