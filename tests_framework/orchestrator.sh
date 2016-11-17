#!/bin/bash
# orchestrator.sh for bear-team
#

test_schemas="array"
test_attributes="1 2 5 10"
logs_dir="logs/"

restart_mongod() {
  # Ugly, but effecient
  pkill mongod
}

start_monitoring() {
  log_dir=$1
  mkdir -p $1

  iostat -xm 1 > $log_dir/iostat.out
  dstat -t -c -d --mongodb-opcount --out $log_dir/dstat.csv > /dev/null
}

stop_monitoring() {
  log_dir=$1
  cp -rf /data/BearMongod/diagnostic.data $log_dir/
  pkill -f dstat
  pkill -f iostat
}


start_testing() {
  for schema in test_schemas; do
    start_testing_dataset $schema
  done
}


start_testing_dataset() {
  schema=$1

  # SMALL
  restart_mongod
  start_testing_attributes $schema

  # MEDIUM
  restart_mongod
  start_testing_attributes $schema

  # LARGE
  restart_mongod
  start_testing_attributes $schema

}

start_testing_attributes() {
  schema=$1
  dataset=$2
  log_dir="$log_dir/`date +'%x-%X'`"

  for attribute in test_attributes; do
    start_monitoring $log_dir
    # TODO PUT GATLING HERE
    stop_monitoring
  done
}



while getopts ":s:a:d:" arg; do
  case $arg in
    s)
      test_schemas=${OPTARG}
      ;;
    a)
      test_attributes=${OPTARG}
      ;;
    d)
      test_datasets=${OPTARG}
      ;;
  esac
done

start_testing
