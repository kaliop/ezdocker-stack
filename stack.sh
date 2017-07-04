#!/usr/bin/env bash

# Script to be used instead of plain docker-compose to build and run the Docker stack

# we allow this to come from shell env if already defined :-)
DOCKER_COMPOSE=${DOCKER_COMPOSE:=docker-compose}

# docker-compose already has an env var existing for this
DOCKER_COMPOSE_FILE=${COMPOSE_FILE:=docker-compose.yml}

# we allow this to come from shell env if already defined :-)
DOCKER_COMPOSE_CONFIG_FILE=${DOCKER_COMPOSE_CONFIG_FILE:=docker-compose.config.sh}


php_available_versions=(5.4 5.6 7 7.1)
available_web_servers=(nginx apache)

usage() {
    echo "Usage: ./stack.sh start|stop|rm|php_switch|web_server_switch|purgelogs|update|reset"
}

# copy template yml file to final docker-compose.yml file
buildDockerComposeFile() {
    if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then

        #choose which template should be used for project

        #docker_compose_template_type=${docker_compose_template_type:-nginx}
        template_file="docker-compose-template.yml"

        #if [ ! -f "$template_file" ]; then
        #    echo "ERROR: wrong template file specified. Aborting ..."
        #    exit 1;
        #fi

        echo "No $DOCKER_COMPOSE_FILE found, copying $template_file ..."
        cp "$template_file" "$DOCKER_COMPOSE_FILE"
    fi
}

buildDockerComposeLocalEnvFileIfNeeded() {
    if [ ! -f 'docker-compose.env.local' ]; then

        echo "Generating config file docker-compose.env.local ...";

        current_uid=`id -u`
        current_gid=`id -g`

        echo "DEV_UID=$current_uid" > docker-compose.env.local
        echo "DEV_GID=$current_gid" >> docker-compose.env.local
    fi
}

configurePhpVersion() {
    read -p "[?] Which PHP version do you want to use? 5.4, [5.6], 7 or 7.1: " php_version
    php_version=${php_version:-5.6}

    if [[ ! " ${php_available_versions[@]} " =~ " ${php_version} " ]]; then
        echo "ERROR: unsupported PHP version ${php_version}. Aborting ..."
        exit 1;
    fi

    # Register php version Docker env variable
    php_version='php'${php_version/./}
    if grep -q DOCKER_PHP_VERSION "$DOCKER_COMPOSE_CONFIG_FILE"; then
     sed -i '/DOCKER_PHP_VERSION/c\export DOCKER_PHP_VERSION='$php_version "$DOCKER_COMPOSE_CONFIG_FILE" ;
    else
     echo "export DOCKER_PHP_VERSION=$php_version" >> $DOCKER_COMPOSE_CONFIG_FILE
    fi

   # Register php config path Docker env variable
   if [[ "$php_version" == 'php7' ]]; then
        php_config_path="/etc/php/7.0"
   else
       if [[ "$php_version" == 'php71' ]]; then
          php_config_path="/etc/php/7.1"
       else
          php_config_path="/etc/php5"
       fi
   fi

   if grep -q DOCKER_PHP_CONF_PATH "$DOCKER_COMPOSE_CONFIG_FILE"; then
     sed -i '/DOCKER_PHP_CONF_PATH/c\export DOCKER_PHP_CONF_PATH='$php_config_path "$DOCKER_COMPOSE_CONFIG_FILE" ;
    else
     echo "export DOCKER_PHP_CONF_PATH=$php_config_path" >> $DOCKER_COMPOSE_CONFIG_FILE
    fi

    source $DOCKER_COMPOSE_CONFIG_FILE
    echo "Selected $php_version as PHP version"
}

configureWebServer() {
    source $DOCKER_COMPOSE_CONFIG_FILE
    read -p "[?] Which web server do you want to use? [apache] or nginx: " web_server_type
    web_server_type=${web_server_type:-apache}

    if [[ ! " ${available_web_servers[@]} " =~ " ${web_server_type} " ]]; then
        echo "ERROR: unsupported web server ${web_server_type}. Aborting ..."
        exit 1;
    fi

    # Check web_server & php combination
    if [[ "$DOCKER_PHP_VERSION" == 'php71' && "$web_server_type" != 'nginx' ]]; then
        echo "Sorry, PHP 7.1 is only available with nginx for the moment."
        echo "Current PHP version: $DOCKER_PHP_VERSION. Aborting ..."
        exit 1;
    fi

    if grep -q DOCKER_WEB_SERVER "$DOCKER_COMPOSE_CONFIG_FILE"; then
     sed -i '/DOCKER_WEB_SERVER/c\export DOCKER_WEB_SERVER='$web_server_type "$DOCKER_COMPOSE_CONFIG_FILE" ;
    else
     echo "export DOCKER_WEB_SERVER=$web_server_type" >> $DOCKER_COMPOSE_CONFIG_FILE
    fi

    echo "Selected $web_server_type as web server"
}
# Check if some files mounted as volumes exist, and create them if they are not found
checkRequiredFiles() {
     if [ ! -f ~/.gitconfig ]; then
        echo "~/.gitconfig file not found. Creating empty file"
        touch ~/.gitconfig
        if [ ! -f ~/.gitconfig ]; then
             echo "~/.gitconfig file can not be created! Aborting ..."
             exit 1;
        fi
    fi

      if [ ! -f ~/.ssh/config ]; then
        echo "~/.ssh/config file not found. Creating empty file"
        touch ~/.ssh/config
        if [ ! -f ~/.ssh/config ]; then
             echo "~/.ssh/config file can not be created! Aborting ..."
             exit 1;
        fi
    fi
}

buildDockerComposeConfigFileIfNeeded() {
    if [ ! -f "$DOCKER_COMPOSE_CONFIG_FILE" ]; then

        echo "Generating config file $DOCKER_COMPOSE_CONFIG_FILE ...";

        read -p "[?] What is your main project name? " DOCKER_PROJECT_NAME
        DOCKER_PROJECT_NAME=${DOCKER_PROJECT_NAME:-myproject}

        read -p "[?] Will you use this docker stack for only one project? y/[n]: " site_project
        site_project=${site_project:-n}

        if [ "$site_project" = "y" ]
        then
            # Unique site stack
            www_root="./site/"
            www_dest="/var/www/site/"

            # Check if site folder exists, otherwise clone project into site folder
            if [ ! -d 'site' ]
            then
                #echo "'site' folder does not exist, remember to clone your project in there"

                # In order to make this better than just letting the dev run git clone, we should check many more things...
                # F.e. build the git url automatically using the Git repo if the given url is not full.
                read -p "[?] 'site' folder does not exist. Please type the Git full url to clone your project: " git_url
                git ls-remote "$git_url" &>-
                if [ "$?" -ne 0 ]; then
                    echo "ERROR: invalid or empty git repository. Aborting ..."
                    exit 1;
                fi

                git clone $git_url site
            fi

        else
            # Multi site stack
            read -p "[?] Full path of your projects on your host machine [/home/$(whoami)/www]: " www_root
            www_root=${www_root:-/home/$(whoami)/www}

            if [ ! -d "$www_root" ]; then
        		echo "Root directory $www_root does not exist! Aborting ..."
        		exit ;
        	fi

            www_dest="/var/www"
        fi

        # Ask for storage mountpoints
        read -p "[?] Path to your ezpublish storages on host [/mnt/\$USER]: " storage_local_path
        storage_local_path=${storage_local_path:-/mnt/\$USER}

        echo "Your local storage folder will be mounted in '/mnt/$USER' inside containers"
        echo "(Don't forget to symlink your storage in your ez5 instance after first run)"

        # Ask for timezone for docker args (needs docker-compsoe v2 format)
        read -p "[?] Current timezone [Europe/Paris]: " timezone
        timezone=${timezone:-Europe/Paris}

        echo "Writing timezone to PHP config ..."
        echo -e "[Date]\ndate.timezone=$timezone" > config/cli/php5/timezone.ini
        echo -e "[Date]\ndate.timezone=$timezone" > config/apache/php5/timezone.ini
        echo -e "[Date]\ndate.timezone=$timezone" > config/nginx/php/timezone.ini

        # Ask for custom vcl file path
        read -p "[?] Path to Varnish vcl file [./config/varnish/ez54.vcl]: " vcl_filepath
        vcl_filepath=${vcl_filepath:-./config/varnish/ez54.vcl}

        # Ask for custom solr conf folder path
        read -p "[?] Path to solr configuration folder [./config/solr]: " solr_conf_path
        solr_conf_path=${solr_conf_path:-./config/solr}

        # Save all env vars in a file that will be included at every call
        echo "# in this file we define all env variables used by docker-compose.yml" > $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_WWW_ROOT=$www_root" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_WWW_DEST=$www_dest" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_PROJECT_NAME=$DOCKER_PROJECT_NAME" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_VARNISH_VCL_FILE=$vcl_filepath" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_SOLR_CONF_PATH=$solr_conf_path" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_STORAGE_LOCAL_PATH=$storage_local_path" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_STORAGE_MOUNT_POINT=/mnt/\$USER" >> $DOCKER_COMPOSE_CONFIG_FILE

        #Configure PHP version
        configurePhpVersion
        configureWebServer
    fi
}

purgeLogs() {
    # q: why are we limiting to .log files and depth ?
    echo "Deleting existing log files:"
    find logs/ -maxdepth 2 -name "*.log*"

    find logs/ -maxdepth 2 -name "*.log*" -delete
}

update() {
    git pull
}

# ### Live code starts here ###

buildDockerComposeFile
buildDockerComposeConfigFileIfNeeded
buildDockerComposeLocalEnvFileIfNeeded
checkRequiredFiles

source $DOCKER_COMPOSE_CONFIG_FILE


case "$1" in

    start|run)
        if [ ! $DOCKER_PHP_VERSION ]; then
           configurePhpVersion
        fi

        if [ ! $DOCKER_WEB_SERVER ]; then
           configureWebServer
        fi

        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" down
        #Always pull latest images from Docker hub
        $DOCKER_COMPOSE pull
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" up -d
        ;;

    stop)
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" stop
        ;;

    rm)
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" rm --force
        ;;

    php_switch)
        configurePhpVersion
        ;;

    web_server_switch)
        configureWebServer
        ;;

    reset)
        rm $DOCKER_COMPOSE_CONFIG_FILE
        rm docker-compose.env.local
        rm $DOCKER_COMPOSE_FILE
        ;;

    purgelogs)
        purgeLogs
        ;;

    update)
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" down
        update
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" up -d
        ;;

    '')
        usage
        exit
        ;;

    *)
        # any other variation, let it go directly through to docker-compose
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" $@

esac
