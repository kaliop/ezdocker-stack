Varnish 4 Docker image
=====================

This image (based on Debian Jessie) runs Varnish 4.1.6 on port 81.  
varnishncsa and varnish-agent are also installed in the container.  


How to run the container
--------------------------------

* If you are working behind a corporate http proxy, run [the klabs/forgetproxy container](https://registry.hub.docker.com/u/klabs/forgetproxy/)
* Run the container

You can run the container with the docker run command :


  ``` sh
    docker run klabs/varnish41
    ```

 But is is strongly recommended to use docker-compose with the stack.sh script provided in [ezdocker-stack](https://github.com/kaliop/ezdocker-stack/) repository.

## How to use docker-compose to run container

First install docker-compose : 

``` sh
curl -L https://github.com/docker/compose/releases/download/1.6.0/docker-compose-`uname -s`-`uname -m` > ~/bin/docker-compose
chmod +x ~/bin/docker-compose
``` 

Then run the container with the following command : 

``` sh
docker-compose up -d
``` 

If you wish to add more options to docker compose, you will have to create your own project.yml file which will extend the one present in this repository.  
Here is an example : 

* Create a project.yml file in your home folder

* Add the following lines in your yml file :


    varnish:
      extends:
        file: /home/user/docker/varnish4/docker-compose.yml
        service: varnish4
      image: klabs/varnish41
      volumes:
       - /home/user/www/project/doc/varnish/vcl/config.vcl:/etc/varnish/default.vcl
      links:
       - web


This will start a varnish container with your project specific vcl file as Varnish default vcl, and link the Varnish container to your 'web' container (Apache)

* Run docker-compose by specifying your own yml file : 

``` sh
docker-compose -f /path/to/project.yml -p my_project_name up -d
``` 