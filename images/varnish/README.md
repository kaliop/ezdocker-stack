Varnish 4 Container
===================

This container (based on Debian 8) runs Varnish 4.0.3 on port 81.  
varnishncsa and varnish-agent are also installed in the container.  
The default vcl used in this container is the one provided by ezsystems for eZ Publish 5.4.


How to build & run the container
--------------------------------

* Check out this repository in a directory somewhere, and execute commands within it 
* If you are working behind a corporate http proxy, run [the klabs/forgetproxy container](https://registry.hub.docker.com/u/klabs/forgetproxy/)
* Build the image


``` sh
docker build -t kaliop/varnish4 .
```

If the build fails when fetching APT repositories/packages , try to build the image without cache :
    
``` sh
docker build --no-cache -t kaliop/varnish4 .
```

## How to use docker-compose to run container

First install docker-compose : 

``` sh
curl -L https://github.com/docker/compose/releases/download/1.6.0/docker-compose-`uname -s`-`uname -m` > ~/bin/docker-compose
chmod +x ~/bin/docker-compose
``` 

Then run the container with the following command : 

``` sh
docker-compose -p kaliop up -d
``` 

If you wish to add more options to docker compose, you will have to create your own project.yml file which will extend the one present in this repository.  
Here is an example : 

* Create a project.yml file in your home folder

* Add the following lines in your yml file :


    varnish:
      extends:
        file: /home/user/docker/varnish4/docker-compose.yml
        service: varnish4
      image: kaliop_varnish4
      volumes:
       - /home/user/www/project/doc/varnish/vcl/config.vcl:/etc/varnish/default.vcl
      links:
       - web


This will start a varnish container with your project specific vcl file as Varnish default vcl, and link the Varnish container to your 'web' container (Apache)

* Run docker-compose by specifying your own yml file : 

``` sh
docker-compose -f /path/to/project.yml -p my_project_name up -d
``` 