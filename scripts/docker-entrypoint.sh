#!/bin/bash
set -e

while test $# -gt 0; do
        case "$1" in
                --wait-for-db-and-migrate)
                        shift
                        DB_MIGRATE=1
                        WAIT_FOR_DB=1
                        ;;
                --db-migrate-only)
                        shift
                        DB_MIGRATE=1
                        RUN_APP=0
                        ;;
                *)
                        break
                        ;;
        esac
done

DB_MIGRATE=${DB_MIGRATE:-0}
WAIT_FOR_DB=${WAIT_FOR_DB:-0}
RUN_APP=${RUN_APP:-1}

echo "DB_MIGRATE: $DB_MIGRATE"
echo "WAIT_FOR_DB: $WAIT_FOR_DB"
echo "RUN_APP: $RUN_APP"

DB_MIGRATION_COMMAND="java -Dspring.main.web-application-type=none -jar application.jar"

if [ "$DB_MIGRATE" == "1" ]
then
  if [ "$WAIT_FOR_DB" == "1" ]
  then
    i=0
    until $DB_MIGRATION_COMMAND || [ $i -ge 60 ]
    do
      i=$((i + 1))
      echo "Waiting for database... $i"
      sleep 1
    done
  else
    $DB_MIGRATION_COMMAND
  fi
fi

if [ "$RUN_APP" == "1" ]
then
  exec java -Dspring.liquibase.enabled=false -jar application.jar
fi