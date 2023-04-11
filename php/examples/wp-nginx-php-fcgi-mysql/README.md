# About

A simple example that shows how one can do an end-to-end deployment of WordPress using Nginx, php-cgi-wasmedge.wasm and MySQL.

# Prerequisites

 - You would need a Docker Desktop installation with enabled containerd and Wasm support.
 - The orchestration is done in a `bash` script.

# [~3 min] How to run

1. Checkout the repository. Then `cd` to this folder.

2. Execute the `run_me.sh` script and wait for the automation to finish.

3. Open [http://localhost:8080/wp-admin/](http://localhost:8080/wp-admin/) and login with the indicated credentials.

Here is a sample session:

```shell-session
User:~/WLR/php/examples/wp-nginx-php-fcgi-mysql \>./run_me.sh

Step 0 | 2023-04-11T19:15:55+03:00 | Cleanup pre-existing containers and data in '/home/User/WLR/php/examples/wp-nginx-php-fcgi-mysql/wlr-tmp'
[sudo] password for User:

Step 1 | 2023-04-11T19:15:59+03:00 | Prepare folders...
Step 2 | 2023-04-11T19:15:59+03:00 | Start services...
Step 3 | 2023-04-11T19:16:03+03:00 | Change default authentication plugin for 'wnpfm-db-container'...
Step 4 | 2023-04-11T19:16:35+03:00 | Setup Wordpress DB 'WordPress' with user 'admin' and password 'password'...
Step 5 | 2023-04-11T19:16:36+03:00 | Download Wordpress...
Step 6 | 2023-04-11T19:16:37+03:00 | Setup Wordpress...

Go to http://localhost:8080/wp-admin/ and login with user='wp_admin' password='wp_admin_password'!                                                                                                                                  
```

# Under the hood

The script shows how one can setup the different services with a typical docker-compose file.

Additional configuration is handled as an additional step in the script but can be moved to an extra service in the docker-compose setup, which does the final configuration.

Note that security concerns about the deployment are not addressed for simplicity. For example, all services are mapped with ports on the host machine and there is no TLS configuration.

## Setting up the services

The `run_me.sh` script will call on docker-compose to:

  1. Build an image based on php-cgi-wasmedge.wasm, optimized for the current machine.
  2. Run a container with a PHP FastCGI server (using the above image and the io.containerd.wasmedge.v1 runtime).
  3. Run an nginx container that forwards .php calls to the fcgi server.
  4. Run a MySQL container.

All services use folders in `$PWD/wlr-tmp` to store the nginx config, PHP content and the DB file.

## Additional configuration

After `docker-compose`, the script proceeds on to:

 1. Setup a MySQL user and database for use with WordPress
 2. Download WordPress and set it up with a hardcoded name, description and credentials
