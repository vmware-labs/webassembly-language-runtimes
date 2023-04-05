#!/usr/bin/env bash

if [[ "$(realpath $PWD)" != "$(realpath $(dirname $BASH_SOURCE))" ]]
then
  echo "This script works only if called from its location as PWD"
  exit 1
fi

step_count=0
demo_step () {
  echo
  echo "================================================"
  echo "Step ${step_count} | $(date --iso-8601=s) | $@"
  step_count=$(expr $step_count + 1)
}

export TEST_USER=test_user
export TEST_PASSWORD=test_password
export MYSQL_CONTAINER_NAME=mysql-wlr-php-test
export TEST_DB_PATH=$PWD/wlr-tmp/data
export TEST_DB=test_db

demo_step Cleanup pre-existing data in "'${TEST_DB_PATH}'" and container "'${MYSQL_CONTAINER_NAME}'"
docker stop ${MYSQL_CONTAINER_NAME}
docker rm -f ${MYSQL_CONTAINER_NAME}
sudo rm -rf ${TEST_DB_PATH}
if (docker ps -a | grep ${MYSQL_CONTAINER_NAME} 2>/dev/null); then
    echo "Failed to remove the ${MYSQL_CONTAINER_NAME} container"
    exit 1
fi

demo_step Run the mysql container "'${MYSQL_CONTAINER_NAME}'". User 'root', password 'root'
docker run -d --name ${MYSQL_CONTAINER_NAME} -p 3306:3306 -v ${TEST_DB_PATH}:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=root mysql
until nc -z localhost 3306
do
    echo "Waiting for container to start..."
    sleep 1
done

until docker exec ${MYSQL_CONTAINER_NAME} mysql -uroot -proot
do
    echo "Waiting for mysqld to become ready..."
    sleep 10
done

demo_step Create ${TEST_DB}
docker exec ${MYSQL_CONTAINER_NAME} mysql -uroot -proot -e "CREATE DATABASE ${TEST_DB};"

demo_step Create sample tables in the ${TEST_DB} database
docker exec ${MYSQL_CONTAINER_NAME} mysql -h 127.0.0.1 -P 3306  -uroot -proot ${TEST_DB} -e \
  'CREATE TABLE IF NOT EXISTS test1 (id int(10) NOT NULL AUTO_INCREMENT, name varchar(50) NOT NULL DEFAULT "", PRIMARY KEY(id) )'
docker exec ${MYSQL_CONTAINER_NAME} mysql -h 127.0.0.1  -P 3306 -uroot -proot ${TEST_DB} -e 'show tables'

demo_step "Configure ${TEST_USER}@ANYHOST / ${TEST_PASSWORD} for mysql_native_password authentication. We don't have OpenSSL, so no sha2 in mysqld in PHP"
sleep 1
docker exec ${MYSQL_CONTAINER_NAME} mysql -h 127.0.0.1 -P 3306 -uroot -proot -e "CREATE USER '${TEST_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${TEST_PASSWORD}'"
docker exec ${MYSQL_CONTAINER_NAME} mysql -h 127.0.0.1 -P 3306 -uroot -proot ${TEST_DB} -e "GRANT ALL PRIVILEGES ON ${TEST_DB}.* TO '${TEST_USER}'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"

demo_step "Change default authentication plugin"
sleep 1
docker exec ${MYSQL_CONTAINER_NAME} sed -i 's!# default-authentication-plugin=mysql_native_password!default-authentication-plugin=mysql_native_password!g' /etc/my.cnf
docker restart ${MYSQL_CONTAINER_NAME}

demo_step "Show users and tables"
sleep 1
docker exec ${MYSQL_CONTAINER_NAME} mysql -h 127.0.0.1 -P 3306 -uroot -proot mysql -e 'SHOW VARIABLES LIKE "default_authentication_plugin"';
docker exec ${MYSQL_CONTAINER_NAME} mysql -h 127.0.0.1 -P 3306 -uroot -proot mysql -e "SELECT User,Host,plugin,password_last_changed FROM user WHERE User='${TEST_USER}';"
docker exec ${MYSQL_CONTAINER_NAME} mysql -h 127.0.0.1 -P 3306 -uroot -proot mysql -e "SHOW GRANTS FOR ${TEST_USER};";

demo_step "Validate access for user '${TEST_USER}'"
sleep 1
docker exec ${MYSQL_CONTAINER_NAME} mysql -h 127.0.0.1 -P 3306 -u${TEST_USER} -p${TEST_PASSWORD} ${TEST_DB} -e "show tables";
docker exec ${MYSQL_CONTAINER_NAME} mysql -h 127.0.0.1 -P 3306 -u${TEST_USER} -p${TEST_PASSWORD} ${TEST_DB} -e \
    "CREATE TABLE sample(id INT(2) PRIMARY KEY, name VARCHAR(30) NOT NULL, description VARCHAR(30) NOT NULL);"


demo_step Build PHP if not available
# TODO - download from github after release
if [ ! -f ../../../build-output/php/php-8.2.0-wasmedge/bin/php-wasmedge.wasm ];
then
  (cd ../../..; WLR_BUILD_FLAVOR=wasmedge ./wlr-make.sh php/php-8.2.0) || exit 1
fi

demo_step Test mySQL with PHP.
sleep 1
wasmedge --dir /test:$(pwd) --env TEST_USER=${TEST_USER} --env TEST_PASSWORD=${TEST_PASSWORD} ../../../build-output/php/php-8.2.0-wasmedge/bin/php-wasmedge.wasm -f /test/test_mysql.php
