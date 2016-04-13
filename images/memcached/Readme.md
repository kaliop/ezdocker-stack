# MEMCACHED

The memcached server for eZ Publish and session storage. This container will set itself up and is already configured.

You should have no need to change or enter this container.

## How to build & run the container

* Check out this repository in a directory somewhere, and execute commands within it
* If you are working behind a corporate http proxy, run [the klabs/forgetproxy container](https://registry.hub.docker.com/u/klabs/forgetproxy/)
* Build the image

    NOTE: Please check the language settings and time zone. You will need to manually change these from the UK settings.

    ``` sh
    docker build -t kaliop/memcaches:1.4 .
    ```

    If the build fails when fetching APT repositories/packages , try to build the image without cache :

    ``` sh
    docker build --no-cache -t kaliop/memcached:1.4 .
    ```

* Run the container

    You will run the container using docker-compose. Please refer to the respository [ReadMe](../../ReadMe.md) for instructions.
