#!/usr/bin/env bash

# Script to be used instead of plain docker-compose to build and run the Docker stack

# we allow this to come from shell env if already defined :-)
DOCKER_COMPOSE=${DOCKER_COMPOSE:=docker-compose}

# docker-compose already has an env var existing for this
DOCKER_COMPOSE_FILE=${COMPOSE_FILE:=docker-compose.yml}

# we allow this to come from shell env if already defined :-)
DOCKER_COMPOSE_CONFIG_FILE=${DOCKER_COMPOSE_CONFIG_FILE:=docker-compose.config.sh}

usage() {
    echo "Usage: ./stack.sh build/start/stop/rm/php_switch/purgelogs/reset"
}

# copy template yml file to final docker-compose.yml file
buildDockerComposeFile() {
    if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then

        #choose which template should be used for project
        read -p "What kind of stack do you want to use ? (possible values are : dev, frontend - default: dev) " docker_compose_template_type
        docker_compose_template_type=${docker_compose_template_type:-dev}
        template_file="docker-compose-$docker_compose_template_type-template.yml"

        if [ ! -f "$template_file" ]; then
            echo "ERROR ! wrong template file specified : aborting ..."
            exit 1;
        fi

        echo "No DOCKER_COMPOSE_FILE file found, generating one from template: $template_file"
        cp "$template_file" "$DOCKER_COMPOSE_FILE"
    fi
}

buildDockerComposeLocalEnvFileIfNeeded() {
    if [ ! -f 'docker-compose.env.local' ]; then

        echo "Generating config file docker-compose.env.local...";

        current_uid=`id -u`
        current_gid=`id -g`

        echo "DEV_UID=$current_uid" > docker-compose.env.local
        echo "DEV_GID=$current_gid" >> docker-compose.env.local
    fi
}


configurePhpVersion() {
    read -p "Which PHP version do you need to use for your project ? (possible values are : 5.4 or 5.6 - default: 5.6) " php_version
    php_version=${php_version:-5.6}
    php_version='php'${php_version/./}

    #echo 'php version : '$php_version
    if grep -q DOCKER_PHP_VERSION "$DOCKER_COMPOSE_CONFIG_FILE"; then
     sed -i '/DOCKER_PHP_VERSION/c\export DOCKER_PHP_VERSION='$php_version "$DOCKER_COMPOSE_CONFIG_FILE" ;
    else
     echo "export DOCKER_PHP_VERSION=$php_version" >> $DOCKER_COMPOSE_CONFIG_FILE
    fi

}

# Check if some files mounted as volumes exist, and create them if they are not found
checkRequiredFiles() {
     if [ ! -f ~/.gitconfig ]; then
        echo "~/.gitconfig file not found. Creating empty file"
        touch ~/.gitconfig
     fi

      if [ ! -f ~/.ssh/config ]; then
        echo "~/.ssh/config file not found. Creating empty file"
        touch ~/.ssh/config
     fi
}

buildDockerComposeConfigFileIfNeeded() {
    if [ ! -f "$DOCKER_COMPOSE_CONFIG_FILE" ]; then

        echo "Generating config file $DOCKER_COMPOSE_CONFIG_FILE...";

        read -p "What is your main project name ? : " DOCKER_PROJECT_NAME
        DOCKER_PROJECT_NAME=${DOCKER_PROJECT_NAME:-myproject}

        read -p "Will you use this docker stack for only one project ? [default: no] (y/n) : " site_project
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

                # In order to make this better than just letting the dev run git clone, we shold check many more things...
                # F.e. build the git url automatically using the Git repo if the given url is not full...
                read -p "'site' folder does not exist: please type the Git full url to clone your project : " git_url
                git ls-remote "$git_url" &>-
                if [ "$?" -ne 0 ]; then
                    echo "ERROR ! invalid or empty git repository : aborting ..."
                    exit 1;
                fi

                git clone $git_url site
            fi

        else
            # Multi site stack
            read -p "Enter the full root path of your projects on your host machine (default: /home/$(whoami)/www/): " www_root
            www_root=${www_root:-/home/$(whoami)/www}

            if [ ! -d "$www_root" ]; then
        		echo "Root directory $www_root does not exist ! Aborting ..."
        		exit ;
        	fi

            www_dest="/var/www/"
        fi

        # Ask for storage mountpoints
        read -p "Enter path to your ezpublish storages on host (default : /mnt/\$USER/ ) : " storage_local_path
        storage_local_path=${storage_local_path:-/mnt/\$USER/}

        echo "Your local storage folder will be mounted in /mnt/$USER inside containers"
        echo "(Don't forget to symlink your storage in your ez5 instance after 1st run)"

        # Ask for timezone for docker args (needs docker-compsoe v2 format)
        read -p "Enter your current timezone (default: Europe/Paris) : " timezone
        timezone=${timezone:-Europe/Paris}

        echo "Configuring timezone for php ..."
        echo -e "[Date]\ndate.timezone=$timezone" > config/cli/php5/timezone.ini
        echo -e "[Date]\ndate.timezone=$timezone" > config/apache/php5/timezone.ini

        # Ask for custom vcl file path
        read -p "Enter path to Varnish vcl file (default: ./config/varnish/ez54.vcl) : " vcl_filepath
        vcl_filepath=${vcl_filepath:-./config/varnish/ez54.vcl}

        # Ask for custom solr conf folder path
        read -p "Enter path to solr configuration folder (default: ./config/solr) : " solr_conf_path
        solr_conf_path=${solr_conf_path:-./config/solr}

        # Save all env vars in a file that will be included at every call
        echo "# in this file we define all env variables used by docker-compose.yml" > $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_WWW_ROOT=$www_root" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_WWW_DEST=$www_dest" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_PROJECT_NAME=$DOCKER_PROJECT_NAME" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_VARNISH_VCL_FILE=$vcl_filepath" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_SOLR_CONF_PATH=$solr_conf_path" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_STORAGE_LOCAL_PATH=$storage_local_path" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_STORAGE_MOUNT_POINT=/mnt/\$USER/" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_TIMEZONE=$timezone" >> $DOCKER_COMPOSE_CONFIG_FILE

        #Configure PHP version
        configurePhpVersion
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

#echo "Using existing $DOCKER_COMPOSE_FILE and $DOCKER_COMPOSE_CONFIG_FILE configuration"

#Always pull latest images from Docker hub

case "$1" in

    start|run)
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" down
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
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" down
        configurePhpVersion
        $DOCKER_COMPOSE pull
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" up -d
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