# DEV-CLI

This is the command-line container for the project. All shell commands should be run from here.

Container is built on Debian jessie

The software packages installed are:

* PHP 5.6
* ImageMagick 6.7
* Composer
* GIT
* Curl
* Vim
* Mysql client
* JAVA (OpenJDK 7)

Your SSH key is passed through to the server as well so you can utilise your normal GIT operations if necessary when
using composer install|update.

The user account you should use to run any operation within the container is: 'user'.

    ``` sh
    docker exec -ti <id of the container> su site
    ```

The root directory of the site is '/var/www/'.

## How to build & run the container

* Check out this repository in a directory somewhere, and execute commands within it
* If you are working behind a corporate http proxy, run [the klabs/forgetproxy container](https://registry.hub.docker.com/u/klabs/forgetproxy/)
* Build the image

    NOTE: Please check the language settings and time zone. You will need to manually change these from the UK settings.

    ``` sh
    docker build -t ez_php .
    ```

    If the build fails when fetching APT repositories/packages , try to build the image without cache :

    ``` sh
    docker build --no-cache -t ez_php .
    ```

* Run the container

You should run the container using docker-compose. Please refer to the respository [ReadMe](../../ReadMe.md) for instructions.
