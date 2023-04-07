#!/usr/bin/env bash

# DISCLAIMER - this is an illustrative example. It includes a lot of bad security practices.

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


export WNPFM_HOST_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
export WNPFM_HOST_PORT=8080
export WNPFM_PHP_FCGI_PORT=9000

export WNPFM_TEST_DIR=$PWD/wlr-tmp

export WNPFM_DB_ROOT_PASSWORD=password
export WNPFM_DB_CONTAINER_NAME=wnpfm-db-container

export WNPFM_DB_WP_DB_NAME=WordPress
export WNPFM_DB_WP_DB_USER=admin
export WNPFM_DB_WP_DB_PASSWORD=password

export WNPFM_WP_ADMIN=wp_admin
export WNPFM_WP_ADMIN_PASSWORD=wp_admin_password


demo_step Cleanup pre-existing containers and data in "'${WNPFM_TEST_DIR}'"
docker-compose down
sudo rm -rf ${WNPFM_TEST_DIR}


demo_step Prepare folders
mkdir -p ${WNPFM_TEST_DIR}/db
mkdir -p ${WNPFM_TEST_DIR}/logs/nginx
mkdir -p ${WNPFM_TEST_DIR}/wordpress

echo "Hello there! General Kenobi!" > ${WNPFM_TEST_DIR}/wordpress/test.html
echo '<?php phpinfo(); php?>' > ${WNPFM_TEST_DIR}/wordpress/test.php


demo_step Start services
docker-compose up -d


demo_step "Change default authentication plugin for '${WNPFM_DB_CONTAINER_NAME}'"
until docker exec ${WNPFM_DB_CONTAINER_NAME} mysql -h 127.0.0.1 -P 3306 -uroot -p${WNPFM_DB_ROOT_PASSWORD}
do
    echo "Waiting for mysqld to become ready..."
    sleep 10
done
docker exec ${WNPFM_DB_CONTAINER_NAME} sed -i 's!# default-authentication-plugin=mysql_native_password!default-authentication-plugin=mysql_native_password!g' /etc/my.cnf
docker restart ${WNPFM_DB_CONTAINER_NAME}
until docker exec ${WNPFM_DB_CONTAINER_NAME} mysql -h 127.0.0.1 -P 3306 -uroot -p${WNPFM_DB_ROOT_PASSWORD}
do
    echo "Waiting for mysqld to become ready..."
    sleep 10
done


demo_step "Setup Wordpress DB '${WNPFM_DB_WP_DB_NAME}' with user '${WNPFM_DB_WP_DB_USER}' and password '${WNPFM_DB_WP_DB_PASSWORD}' "

docker exec ${WNPFM_DB_CONTAINER_NAME} mysql -uroot -p${WNPFM_DB_ROOT_PASSWORD} -e "CREATE DATABASE ${WNPFM_DB_WP_DB_NAME};"
docker exec ${WNPFM_DB_CONTAINER_NAME} mysql -h 127.0.0.1 -P 3306 -uroot -p${WNPFM_DB_ROOT_PASSWORD} -e "CREATE USER '${WNPFM_DB_WP_DB_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${WNPFM_DB_WP_DB_PASSWORD}'"
docker exec ${WNPFM_DB_CONTAINER_NAME} mysql -h 127.0.0.1 -P 3306 -uroot -p${WNPFM_DB_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${WNPFM_DB_WP_DB_NAME}.* TO '${WNPFM_DB_WP_DB_USER}'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"


demo_step "Download Wordpress"
mkdir /tmp/wnpfm-temp-download 2>/dev/null
echo "34f279efe623025641bc11a69e3c02fa /tmp/wnpfm-temp-download/wordpress-6.2.tar.gz" >/tmp/wnpfm-temp-download/checksum

if ! md5sum -c /tmp/wnpfm-temp-download/checksum --quiet 2>/dev/null; then
  curl -L -o /tmp/wnpfm-temp-download/wordpress-6.2.tar.gz https://wordpress.org/wordpress-6.2.tar.gz
  if ! md5sum -c /tmp/wnpfm-temp-download/checksum --quiet 2>/dev/null; then
    echo "FAILED: download WordPress checksum!"
    exit -1
  fi
fi

tar -xf /tmp/wnpfm-temp-download/wordpress-6.2.tar.gz -C ${WNPFM_TEST_DIR}/wordpress --strip-components=1


demo_step "Setup Wordpress"
(
  cd ${WNPFM_TEST_DIR}/wordpress;
  cp -v wp-config-sample.php wp-config.php
  sed -i "s/^.*DB_NAME.*$/define('DB_NAME', '${WNPFM_DB_WP_DB_NAME}');/" wp-config.php
  sed -i "s/^.*DB_USER.*$/define('DB_USER', '${WNPFM_DB_WP_DB_USER}');/" wp-config.php
  sed -i "s/^.*DB_PASSWORD.*$/define('DB_PASSWORD', '${WNPFM_DB_WP_DB_PASSWORD}');/" wp-config.php

  # MySQL is exposed through the host's IP address. Must be an IP address, not a hostname due to php-cgi.wasm limitations
  sed -i "s/^.*DB_HOST.*$/define('DB_HOST', '${WNPFM_HOST_IP}');/" wp-config.php
)

curl --data-urlencode "weblog_title=WasmLabs on PHP FCGI with MySQL" \
     --data-urlencode "user_name=${WNPFM_WP_ADMIN}" \
     --data-urlencode "admin_password=${WNPFM_WP_ADMIN_PASSWORD}" \
     --data-urlencode "admin_password2=${WNPFM_WP_ADMIN_PASSWORD}" \
     --data-urlencode "admin_email=no-reply@wasmlabs.dev" \
     --data-urlencode "Submit=Install+WordPress" \
     http://localhost:${WNPFM_HOST_PORT}/wp-admin/install.php?step=2


echo "Go to http://localhost:${WNPFM_HOST_PORT}/wp-admin/ and login with user='${WNPFM_WP_ADMIN}' password='${WNPFM_WP_ADMIN_PASSWORD}'"!
