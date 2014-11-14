#!/bin/bash
 
# Die Absoluten Pfade zu den Kommandos
MYSQL_COMMAND='/usr/bin/mysql'
MYSQLDUMP_COMMAND='/usr/bin/mysqldump'
 
# Die Datenbanken
SOURCE_DB=''
TARGET_DB=''
# SOURCE_DB='menalib'
# TARGET_DB='a6agy_menalib'
 
# Aufraeumen in der TARGET_DB
#
# Da der Nutzer keine Rechte zum Loeschen oder Anlegen von Datenbanken hat,
# muss das Aufraeumen "zu Fuss" erfolgen. Dazu holt der Nutzer die Namen
# der Tabellen aus dem information_schema und loescht dann die Tabellen
COMMAND="select table_name from information_schema.tables where table_schema='${TARGET_DB}';"
TABLES=$(\
  echo ${COMMAND} | \
    ${MYSQL_COMMAND} \
      --user=${MYSQL_ITZ_MYSQL_ROOT_USER} \
      --password=${MYSQL_ITZ_MYSQL_ROOT_PASSWORD} \
      --host=${MYSQL_ITZ_MYSQL_ROOT_HOST} \
      --skip-column-names)
 
for TABLE in ${TABLES[@]}
do
  ${MYSQL_COMMAND} \
    --user=${MYSQL_ITZ_MYSQL_ROOT_USER} \
    --password=${MYSQL_ITZ_MYSQL_ROOT_PASSWORD} \
    --host=${MYSQL_ITZ_MYSQL_ROOT_HOST} \
    ${TARGET_DB} -e "drop table ${TABLE}"
done
 
 
# Kopieren der Tabellen von SOURCE_DB nach TARGET_DB
#
# Klassisch mit mysqldump ausgeben und durch eine pipe
# wieder in die Datenbank schicken.
${MYSQLDUMP_COMMAND} \
  --single-transaction \
  --user=${MYSQL_URZ_MYSQL_ROOT_USER} \
  --password=${MYSQL_URZ_MYSQL_ROOT_PASSWORD} \
  --host=${MYSQL_URZ_MYSQL_ROOT_HOST} ${SOURCE_DB} | \
${MYSQL_COMMAND} \
  --user=${MYSQL_ITZ_MYSQL_ROOT_USER} \
  --password=${MYSQL_ITZ_MYSQL_ROOT_PASSWORD} \
  --host=${MYSQL_ITZ_MYSQL_ROOT_HOST} ${TARGET_DB}
