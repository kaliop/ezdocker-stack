# Apache/php 5.6 web server

This is the main web server container for the project. The source code for the eZ Publish installation will be run from here.

Unlike the other containers there is more than one software package installed here as they are necessary for the running of eZ Publish.

Container is built on Ubuntu 14.04

The software packages installed are:

* Apache 2.4
* PHP 5.6
* ImageMagick 6.7
* JAVA (OpenJDK 7)
* Curl

## Apache config

Apache listens on ports:
* 88 (controlpanel vhost)
* NNN (enabled by site vhosts)

Those can be remapped when running the container.

The controlpanel vhost is baked-in into the container, whereas eZ Publish dynamic virtual hosts config files must be mounted as volumes.
This way it is faster to modify a vhost config and restart the Apache service without having to rebuild the container.

## How to run the container

* If you are working behind a corporate http proxy, run [the klabs/forgetproxy container](https://registry.hub.docker.com/u/klabs/forgetproxy/)

* Run the container

You can run the container with the basic run Docker command :


	``` sh
    docker run klabs/apache_php56
    ```

 But is is strongly recommended to use docker-compose with the stack.sh script provided in ezdocker stack repository (https://github.com/kaliop/ezdocker-stack/)