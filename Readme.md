eZ Publish Web Development Environment
============================================================

This repository contains all the Docker images and build files needed to create and use an eZ Publish Development Environment.

It is to be used in conjunction with another repository which will contain the Application source code.
The Application source code can be installed in the 'site' directory within the Development Environment root directory, 
or in your local main projects directory (~/www for example) 


## System Requirements

The development environment is based on Docker containers and requires:

* Docker 1.10.0 or later
* Docker Compose 1.6.0 or later


*IMPORTANT* make sure your installed versions of Docker and Docker Compose are not older than the required ones!

For MacOSX and Windows users, the recommended setup is to use a Debian or Ubuntu VM as host for the containers
(remember to make the current user a member of 'docker' group).
NB: give *at least* 2GB of RAM to the host VM, as it is necessary when running Composer...

The following ports have to be not in use on the host machine:

* 80 website
* 88 a handy control-panel
* 8983 solr
* 3307 mysql
* 11211 memcache

## How it works

The environment is split into containers which execute each one of the main services.

All containers are built from the debian jessie official docker image as this should reflect the software stack installed
on the UAT and Production environments.

Each container image has a Readme file describing it in detail, in the same folder as the image:

* [web](images/web/Readme.md)
* [phpcli](images/cli/Readme.md)
* [solr](images/solr/Readme.md)
* [varnish](images/cli/Readme.md)
* [memcached](images/memcached/Readme.md)
* [mysql](images/mysql/Readme.md)
* [haproxy](images/haproxy/Readme.md)

The following data are stored on the host machine (and mounted as volumes in the containers):

* configuration of the services running in each container: /config/...
* the Mysql data files and Solr index: /data/...
* the Apache, Php, Varnish, Mysql and Solr log files: /logs/...
* the application source code : /site/ or ~/www/

*NB:* if you have never used Docker before, getting a basic knowledge of the commands used to start/stop/attach-to containers
might be a good idea.
There are plenty of tutorials available on the internet. This is a good quickstart: https://docs.docker.com/engine/userguide/basics/


## Setting up the Environment (for 1st time execution)

1. Install Docker and Docker Compose

    Follow the instructions appropriate to your OS.
    F.e. for Ubuntu linux:

    [https://docs.docker.com/engine/installation/ubuntulinux/](https://docs.docker.com/engine/installation/ubuntulinux/)
    
    [https://docs.docker.com/compose/install/](https://docs.docker.com/compose/install/)
    

2. SSH Agent

    Your local ssh-agent is forwarded to the cli container when running. This way the ssh private keys stored in the host
    machine will be made available inside the container, making it easy to connect to the Git repository and other
    remote servers via ssh.

    To make sure your ssh-agent is running, run:

        ssh-add -L

    If you get an error, you can start it manually:

        eval `ssh-agent -s`

    To have ssh-agent automatically launched every time you log on, add this line to your ~/.profile file on the host machine:

        [ -z "$SSH_AUTH_SOCK" ] && eval `ssh-agent -s`


3. Clone the Docker stack Repository

    Most of the files needed to get the environment going are located in this repository with the exception of the app codebase,
    which is stored in another repository and will have to be installed separately once the environment is configured, 
    and some docker images which are also stored in other repositories and imported as git sub modules. 

    To get the required files onto the host machine simply clone this repo into a local folder and install sub modules:

        git clone ssh://git@github.com:kaliop/ezdocker-stack.git
        cd /path/to/your/docker/folder/ezdocker-stack


4. Environment Settings

    Note that all the required environment variables are already set in [docker-compose.env](docker-compose.env), only
    set in  `docker.compose.env.local` the value of any that you need to change.

    * If the user-id and group-id you use on the host machine are not 1000:1000, the stack shell script will set these information automatically in `docker.compose.env.local` file.  
        This will help with avoiding filesystem permissions later on with the web server container mount points.
        To find out the id of the current user/group on the host machine, execute the `id` command.  

    * The MySQL settings are already configured in the eZ Publish environment and on first run an empty database will be
        created ready for you to import the required data as outlined in the setup instructions in the eZPublish repository.
        
    The `docker-compose.config.sh` file contains your project specific settings. It will be generated on first launch but feel free to edit them manually if you need to.


5. Make sure that the config/*, logs/* and data/* subfolders can be written to.

    Some of the containers (currently this includes varnish, apache, solr and mysql) will write log files and data files to those
    directories on the host using a different user/group than the one you are using. You have to make sure that those
    files can be written. In doubt, run:

        find ./config -type d -exec chmod 777 {} \; && find ./data -type d -exec chmod 777 {} \; && find ./logs -type d -exec chmod 777 {} \;


6. Launch the stack script and build the Environment Images

	The docker stack provides a shell script to manage your project's docker-compose file.
	The script is interactive and will ask you a few questions to configure your project the first time you run it.
	Once this is done, `docker.compose.env.local`, `docker-compose.config.sh` and `docker-compose.yml` files will be created in the main folder.
	
	Here are the information you will need to enter in your console to configure your project : 
	
	* Your project name
	* Will the docker stack be used for only one project (ez instance will be cloned in site folder)
	or for many projects already present on your computer ?
	* If the stack is a mono project stack, the Git url of your project.
	* If this is a multi projects stack, the root path of your projects (usually /home/user/www)
	* The local path of your main project storage (usually this will be a folder located on the workspace)
	* The mount point of your main project storage inside the web & cli containers
	* Your current timezone & locale
	* Your main project Varnish VCL file
	* Your solr configuration folder if you need a specific configuration for your project
	* The PHP Version you wish to use (5.4 or 5.6)
	
	To build all images, launch the script with the 'build' argument : 
	
		./stack.sh build

    Note: if you ever want to rebuild the whole platform *from scratch*, making sure that there are no cached container
    images involved, the command to use is: `docker-compose build --force-rm --no-cache`.

    Note: if there are error messages during the build about ubuntu repositories not being accessible or other network
    related errors, and the host is an Ubuntu machine, take a look at this page:
    http://serverfault.com/questions/642981/docker-containers-cant-resolve-dns-on-ubuntu-14-04-desktop-host

    Note: if the build gets stuck while installing java in the solr container, take a look at:
    https://github.com/docker/docker/issues/18180.
    If you are running in virtualbox, setting your vcpu count to 2 might fix the problem...


7. Set up the Application

    Follow the instructions in the Readme file of the application (*nb:* you will most likely have to start the
    containers for that, please read below for instructions)


## Starting the Environment

You can use the `stack.sh` script to start/stop the development environment.

The script will perform the following operations:

1. Stop all running docker containers
2. Start Docker Compose which will start all the containers.

Before running the environment for the first time please verify that the settings are correct for your user and group ids in docker-compose.env.local.

To start the run script navigate to the project folder and run:

    ./stack.sh run or ./stack.sh start

Note: if you get an error about SSH_AUTH_SOCK, see point 2 above
Note: if any of the images fails to start, check the logs via  `docker logs <image_name>` or `docker-compose logs` to see all logs

## Updating the Environment

To pull in the latest changes and restart all the containers, just run:

    ./stack.sh update

*NB:* this will apply any changes coming from the git repository which contains the definition of the stack, but it
will not update the base Docker images in use. If the base images have been updated, because of eg. known security
vulnerabilities, it is recommended to rebuild all the containers by stopping them and the running:

    docker-compose build --pull

Note that this might take a while and need a lot of disk space. Remove unused container images to free some space.


## Changing the environment configuration

The stack configuration is mainly managed by the `docker-compose.yml` file, which is ignored in GIT.
You can therefore edit this file and make all the changes you need for your project, like adding volumes, adding or removing containers, aso ...


## Accessing the application

### Control panel

You can connect to a handy control on port 88:

http://localhost:88/

This panel will give you access to some tools such as PHP info, Apache Info, Varnish agent, Memcached admin, ...

### Websites

To use hostname-based vhosts, you should edit the local hosts file of the computer you are using.
All hostnames used to point to 127.0.0.1 will trigger the same Apache Vhost.

Port 80 is mapped to haproxy server. By default, haproxy will server your pages directly through Apache, but you can choose whether you want to view your website via Varnish or not.  
To do this, you must send a specific header called `Backend` and set the desired value : 

* **front** : access your website through Apache
* **demo**: access your website through Apache using the 'demo' SYMFONY Environment (to test a symfony environment different from dev)
* **varnish** : access your website through Varnish

Note: To send a specific header with Chrome for example, you can use the ModHeader extension : https://chrome.google.com/webstore/detail/modheader/idgpnmonknjnojddfkpgkljpfnnfcklj

### Connecting to the PHP cli (for clearing caches, running composer-install, etc...)

    docker exec -ti cli su site

Note: by default you will be using the 'dev' Symfony environment. To change it, override the SYMFONY_ENV environment variable in `docker-compose.env.local`.
(the default is taken from file docker-compose.env)

### Using Solr admin

Solr admin interface can be accessed either through port 8983, i.e http://localhost:8983, or with the /solr/ url, i.e http://www.mysite.ezdev/solr/ .

## Stopping the Environment

    ./stack.sh stop
    
## Deleting all containers

    ./stack.sh rm
    
## Reset all environment configuration

    ./stack.sh reset
    
This will delete `docker.compose.env.local`, `docker-compose.config.sh` and `docker-compose.yml` files.
The script will ask you for project configuration on next run.

## Delete all log files

    ./stack.sh purgelogs

## Switch PHP version

The cli and web containers run php 5.6 as default version. If you need to switch to PHP 5.4 for your project, use the `php_switch` argument : 

    ./stack.sh php_switch

This will remove web & cli images and rebuild the ez_php5 image with the chosen php version (5.4 or 5.6), which is the source image for cli & web images. 


## Extras

### Connecting to a running container (run a shell session)

List the Ids of all running containers:

    docker ps

Note down id of the container you want to connect to, then run:

    docker exec -it <container-name> bash

Note: do *not* use `docker run` to attach to an existing container, as that will in fact spawn a new container.

Note: to connect to the web or cli containers, use `su site` instead of `bash`

### Checking the status of all existing containers (not only the active ones)

    docker ps -a

### Fixing user permissions

If you connect to the web container to execute commands such as `git pull` or `composer update`, take care: by default
you will be connecting as the root user. Any files written by the root user might be problematic because they will not
be modifiable by the apache webserver user.
Is is thus a better idea to connect to the web server container as the *site* user (used to run apache).

If you have problems with user permissions, just run `sudo chmod -R <localuser>:<localgroup> site` on the host machine,
with the appropriate ids for localuser and localgroup.

### Removing a local image

In case things are horribly wrong:

    docker ps -a
    docker rm <id of the container>
    docker rmi <id of the image>

### Cleaning up orphaned images from your hard disk

Note that when you delete images used by containers, as shown above, you will not be deleting all docker image layers
from your hard disk. To check it out, just run `docker images`...

The best tool we found so far to really clean up leftover image layers is: https://github.com/spotify/docker-gc

### Building individual images

From time to time you may need to rebuild an individual image because there has been an update to the image definition.

First make sure to pull the latest version of the repository. Navigate into the project folder and run a git pull.

    git pull origin master

To rebuild a specific image simply run docker-compose using the image 'service name', e.g.

    docker-compose cli

Note: the phpmyadmin and dockerui images do not need a rebuild build phase. It you remove them (see chapter above), and
run the `stack.php run` command, they will be re-pulled automatically then executed.

### MySQL

This container is forked from the official MySQL container on DockerHub and only minimally tweaked.
You should not need to change anything with this container.

The connection details for the database root user and application user can be found in the docker-compose.env file.

The database data files are stored locally in [data/mysql](data/mysql). You do not need to put anything in there, as
they will be created the first time the container is run, and be persisted when it is shut down.
The created database will be empty, and you will need to fill it up with application data using some SQL or other
script which will be provided as part of the Application.  
If you want to change the database name (default is 'ezdev'), just create an environment variable named `MYSQL_DATABASE` in `docker-compose.env.local` file.

	MYSQL_DATABASE=mydbname

### Connecting to the database from the host machine

Connecting to the db from the host machine is possible. Just remember that:  
to connect to the MySQL server from the host machine, use a command akin to 

	mysql -u<user> -p<password> -h127.0.0.2 -P3307
	
	
(this way the mysql client will not try to use a unix socket connection, as it does when using localhost/127.0.0.1)
