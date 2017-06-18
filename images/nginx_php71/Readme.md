# Nginx/php 7.1 web server

This container runs the Nginx & php-fpm services.

Image is built on Debian Jessie.

The main software packages installed are:

* Nginx 1.2
* PHP 7.1


## Nginx config

Nginx listens on ports:
* 80 (dev vhost)
* 82 (demo vhost)
* 88 (controlpanel vhost)

Those can be remapped when running the container.

The controlpanel vhost is baked-in into the container, whereas other dynamic virtual hosts config files must be mounted as volumes.
This way it is faster to modify a vhost config and restart the Nginx service without having to rebuild the container.

## How to run the container

* If you are working behind a corporate http proxy, run [the klabs/forgetproxy container](https://registry.hub.docker.com/u/klabs/forgetproxy/)

* Run the container

You can run the container with the docker run command :


	``` sh
    docker run klabs/nginx_php71
    ```

 But is is strongly recommended to use docker-compose with the stack.sh script provided in [ezdocker-stack](https://github.com/kaliop/ezdocker-stack/) repository.