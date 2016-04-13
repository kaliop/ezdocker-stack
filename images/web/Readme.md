# WEB

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

The controlpanel vhost is baked-in into the container, whereas the single vhosts config files are mounted as volumes.
This way it is faster to modify a vhost config and restart the Apache service without having to rebuild the container.

## How to build & run the container

* Check out this repository in a directory somewhere, and execute commands within it
* If you are working behind a corporate http proxy, run [the klabs/forgetproxy container](https://registry.hub.docker.com/u/klabs/forgetproxy/)
* Build the image

    NOTE: Please check the language settings and time zone. You will need to manually change these from the UK settings.

    ``` sh
    docker build -t web .
    ```

    If the build fails when fetching APT repositories/packages , try to build the image without cache :

    ``` sh
    docker build --no-cache -t web .
    ```

* Run the container

You should run the container using docker-compose. Please refer to the repository [ReadMe](../../ReadMe.md) for instructions.
