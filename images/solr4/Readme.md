Solr Container
=========

This container runs a 4.10 SOLR server with java 7 installed.  
The SOLR schema is the one provided by ezsystems (from ezfind extension) to be used with ezpublish 5.  
Solr data folder can be mounted from host system to persist data when the container is restarted.
Solr will run by default on port 8983 but you can change the default port when runnning the container.

How to run the container
--------------------------------

* If you are working behind a corporate http proxy, run the [klabs/forgetproxy container](https://registry.hub.docker.com/u/klabs/forgetproxy/)
* Run the container

You can run the container with the basic run Docker command :


	``` sh
    docker run klabs/solr4
    ```

 But is is strongly recommended to use docker-compose with the stack.sh script provided in ezdocker stack repository (https://github.com/kaliop/ezdocker-stack/)

How to enter the container
--------------------------------


	``` sh
	docker exec -ti solr bash
	```

How to restart solr daemon
--------------------------------

* Enter the container

* Run the solr init.d startup command with restart option :

``` sh
/etc/init.d/solr restart
```

How to use docker-compose to run the container
--------------------------------

First install docker-compose :

``` sh
curl -L https://github.com/docker/compose/releases/download/1.6.0/docker-compose-`uname -s`-`uname -m` > ~/bin/docker-compose
chmod +x ~/bin/docker-compose
```

Then run the container with the following command :

``` sh
docker-compose -p solr up -d
```

If you wish to add more options to docker compose, you will have to create your own project.yml file which will extend the one present in this repo.
Here is an example :

* Create a project.yml file in your home folder

* Add the following lines in your yml file :


    solr:
	    extends:
	      file: /home/user/docker/solr/docker-compose.yml
	      service: solr
	    image: kaliop_solr
	    volumes:
	     - /home/user/docker/share/solr_data:/opt/solr/solr/data


* Run docker-compose by specifying your yml file :

``` sh
docker-compose -f /path/to/project.yml -p my_project_name up -d
```