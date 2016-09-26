# MEMCACHED Docker image

The memcached server for eZ Publish and session storage. This image will set itself up and is already configured.

You should have no need to change or enter this container.

## How to run the container

* If you are working behind a corporate http proxy, run [the klabs/forgetproxy container](https://registry.hub.docker.com/u/klabs/forgetproxy/)
* Run the container

You can run the container with the docker run command :


	``` sh
    docker run klabs/memcached
    ```

 But is is strongly recommended to use docker-compose with the stack.sh script provided in [ezdocker-stack](https://github.com/kaliop/ezdocker-stack/) repository.
