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

        echo "No DOCKER_COMPOSE_FILE file found, generating one from template..."
        cp docker-compose-template.yml "$DOCKER_COMPOSE_FILE"
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

buildDockerPhpImage() {

    read -p "Which PHP version do you need to use for your project ? (possible values are : 5.4 or 5.6) " php_version
    php_version=${php_version:-5.6}

    echo "Deleting web and cli images"

    docker images | awk '{print $1,$3}' | grep $DOCKER_PROJECT_NAME"_web" | awk '{print $2}' | xargs -I {} docker rmi --force {}
    docker images | awk '{print $1,$3}' | grep $DOCKER_PROJECT_NAME"_cli" | awk '{print $2}' | xargs -I {} docker rmi --force {}
    docker images | awk '{print $1,$3}' | grep "ez_php" | awk '{print $2}' | xargs -I {} docker rmi --force {}

    echo "Building ez_php image with PHP version $php_version"
    case "$php_version" in

        5.4)
            docker build -f images/php54/Dockerfile -t ez_php --rm --force-rm .
        ;;

        5.6)
            docker build -f images/php56/Dockerfile -t ez_php --rm --force-rm .
        ;;

    esac

    read -p "PHP image succesfully built ? (y/n) " build_success
    if [ ! $build_success == 'y' ]; then
        exit ;
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

        echo "What is your main project name ?"
        read DOCKER_PROJECT_NAME

        echo "Will you use this docker stack for only one project ? (y/n)"
        read site_project

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
                if [ "$git_url" = "" ] || [ "$git_url" != "ssh*" ] || [ "$git_url" != "http*" ]; then
                    echo "ERROR ! invalid or empty git url : aborting ..."
                    exit ;
                fi

                git clone $git_url site
            fi

        else
            # Multi site stack
            read -p "Enter the full root path of your projects on your host machine (Ex : /home/user/www/ ): " www_root
            #read www_root;

            if [ ! -d "$www_root" ]; then
        		echo "Root directory $www_root does not exist ! Aborting ..."
        		exit ;
        	fi

            www_dest="/var/www/"
        fi

        # Ask for storage mountpoints
        read -p "Enter your project ez storage path on host (Ex: /mnt/user/workspace/user/project-ezpublish/var/project/storage/ ) : " storage_local_path
        #storage_local_path=${storage_local_path:-/tmp/storage/}

        if [ ! -d "$storage_local_path" ]; then
        	echo "Directory $storage_local_path does not exist ! Aborting ..."
        	exit ;
        fi


        read -p "Enter your project storage mount point in container (/mnt/storage/) : " storage_mount_point
        storage_mount_point=${storage_mount_point:-/mnt/storage/}

        echo "(Don't forget to symlink your storage in your ez5 instance after 1st run)"

        # Ask for timezone for docker args (needs docker-compsoe v2 format)
        read -p "Enter your current timezone (Europe/Paris) : " timezone
        timezone=${timezone:-Europe/Paris}

        echo "Configuring timezone for php ..."
        echo -e "[Date]\ndate.timezone=$timezone" > config/cli/php5/timezone.ini
        echo -e "[Date]\ndate.timezone=$timezone" > config/web/php5/timezone.ini

		# Ask for locale for docker args (needs docker-compsoe v2 format)
        read -p "Enter your current locale (fr_FR.UTF-8) : " locale
        locale=${locale:-fr_FR.UTF-8}

        # Ask for custom vcl file path
        read -p "Enter path to Varnish vcl file (./config/varnish/ez54.vcl) : " vcl_filepath
        vcl_filepath=${vcl_filepath:-./config/varnish/ez54.vcl}

        # Ask for custom solr conf folder path
        read -p "Enter path to solr configuration folder : (./config/solr) " solr_conf_path
        solr_conf_path=${solr_conf_path:-./config/solr}

        #Ash for PHP version
        buildDockerPhpImage

        # Save all env vars in a file that will be included at every call
        echo "# in this file we define all env variables used by docker-compose.yml" > $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_WWW_ROOT=$www_root" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_WWW_DEST=$www_dest" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_PROJECT_NAME=$DOCKER_PROJECT_NAME" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_VARNISH_VCL_FILE=$vcl_filepath" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_SOLR_CONF_PATH=$solr_conf_path" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_STORAGE_LOCAL_PATH=$storage_local_path" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_STORAGE_MOUNT_POINT=$storage_mount_point" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_TIMEZONE=$timezone" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_LOCALE=$locale" >> $DOCKER_COMPOSE_CONFIG_FILE
    fi
}

purgeLogs() {
    # q: why are we limiting to .log files and depth ?
    echo "Deleting existing log files:"
    find logs/ -maxdepth 2 -name "*.log*"

    find logs/ -maxdepth 2 -name "*.log*" -delete
}


# ### Live code starts here ###

buildDockerComposeFile
buildDockerComposeConfigFileIfNeeded
buildDockerComposeLocalEnvFileIfNeeded
checkRequiredFiles

source $DOCKER_COMPOSE_CONFIG_FILE

#echo "Using existing $DOCKER_COMPOSE_FILE and $DOCKER_COMPOSE_CONFIG_FILE configuration"

case "$1" in

    # @todo shall we escape $DOCKER_COMPOSE for security ?

    build)
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" build
        ;;

    start|run)
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" down
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" up -d
        ;;

    stop)
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" stop
        ;;

	rm)
		$DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" rm --force
		;;

    php_switch)
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" stop
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" rm --force
        buildDockerPhpImage
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" build
        ;;

	reset)
        rm $DOCKER_COMPOSE_CONFIG_FILE
        rm docker-compose.env.local
        rm $DOCKER_COMPOSE_FILE
        ;;

    purgelogs)
        purgeLogs
        ;;

    '')
        usage
        exit
        ;;

    *)
        # any other variation, let it go directly through to docker-compose
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" $@

esac