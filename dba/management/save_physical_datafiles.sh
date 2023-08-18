#!/bin/sh

prefix="$(echo $0 | awk -F. '{print $1}')"
directories="${prefix}.directories"
physicals="${prefix}.physical"
logicals="${prefix}.logical"

clear;

# load distinct directories by query
loadDirectoriesByQuery() {
  query="
  select distinct substr(file_name, 1, instr(file_name, '/', -1) - 1) as datafile_directory
    from (select 'data' as type, file_name, file_id
            from dba_data_files
           union all
          select 'temp' as type, file_name, file_id
            from dba_temp_files
           order by type, file_id);
  "
  result=$(sh ./execute_sql.sh "$query")
  
  echo "$result" > $directories
}
# load physical datafiles
loadPhysicalDatafiles() {
  > $physicals
  while IFS= read -r directory;
  do
    find $directory -maxdepth 1 -mindepth 1 -type f -name "*.dbf" >> $physicals
  done < $directories
}
# load logical datafiles
loadLogicalDatafiles() {
	> $logicals
  query="
  select file_name
    from (select 'data' as type, file_name, file_id
            from dba_data_files
           union all
          select 'temp' as type, file_name, file_id
            from dba_temp_files
           order by type, file_id);
  "
  result=$(sh ./execute_sql.sh "$query")
  
  echo "$result" > $logicals
}
# get delete target: physical minus logical
# get missing target: logical minus physical
getDeleteTargets() {
  > "$0.physical_query"
  echo "select path from (select null as path from dual" >> "$0.physical_query"
  while IFS= read -r line;
  do
		with_single_quotation="'$line'"
		echo " union all select ${with_single_quotation} from dual" >> "$0.physical_query"
  done < "$physicals"
  echo ") where path is not null;"  >> "$0.physical_query"

  physical_result=$(sh ./execute_sql.sh "$(cat "$0.physical_query")" "physical_query")

  > "$0.logical_query"
  echo "select path from (select null as path from dual" >> "$0.logical_query"
  while IFS= read -r line;
  do
		with_single_quotation="'$line'"
    echo " union all select ${with_single_quotation} from dual" >> "$0.logical_query"
  done < "$logicals"
  echo ") where path is not null;"  >> "$0.logical_query"
  logical_result=$(sh ./execute_sql.sh "$(cat "$0.logical_query")" "logical_query")
}
getMissingTargets() {
	echo "missingtargets"
}

loadDirectoriesByQuery
loadPhysicalDatafiles
loadLogicalDatafiles
getDeleteTargets
