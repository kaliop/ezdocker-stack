# PHP 7.1 CLI Docker image

This is a command-line image that can be used for your projects. All shell commands should be run from here.

Image is built on Debian jessie.

The software packages installed are:

* PHP 7.1
* ImageMagick 6.7
* Composer
* GIT
* Curl
* Vim
* Mysql client
* JAVA (OpenJDK 7)

Your SSH key is passed through to the server as well so you can use your normal GIT operations if necessary when
using composer install|update.

The user account you should use to run any operation within the container is: 'user'.

    ``` sh
    docker exec -ti <id of the container> su site
    ```

The root directory of the site is '/var/www/'.

## How to run the container

* If you are working behind a corporate http proxy, run [the klabs/forgetproxy container](https://registry.hub.docker.com/u/klabs/forgetproxy/)
* Run the container

You can run the container with the docker run command :


    ``` sh
    docker run klabs/cli_php71
    ```

 But is is strongly recommended to use docker-compose with the stack.sh script provided in [ezdocker-stack](https://github.com/kaliop/ezdocker-stack/) repository.
