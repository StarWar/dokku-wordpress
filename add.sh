#!/bin/bash

# get app name
echo "Enter the new app name:"
read APP_NAME

# get domain info
echo "Enter the apps domain name:"
read DOMAIN

# is this a wordpress app
echo "Is this a Wordpress app: (y/n)"
read IFWP

if [[ ( $IFWP == "y" ) || ( $IFWP == "Y" ) || ( $IFWP == "yes" ) || ( $IFWP == "Yes" ) || ( $IFWP == "YES" ) ]];

then
    # create the app
    dokku apps:exists "$APP_NAME" || dokku apps:create "$APP_NAME"
    
    # setup the domain
    dokku domains:clear "$APP_NAME"
    dokku domains:add "$APP_NAME" "$DOMAIN"
    dokku domains:add "$APP_NAME" www."$DOMAIN"
    dokku domains:remove "$APP_NAME" "$APP_NAME"."$HOSTNAME"
    
    # get directories setup for persistent storage
    sudo mkdir -p /var/lib/dokku/data/storage/"$APP_NAME"/wp-content/uploads
    sudo mkdir -p /var/lib/dokku/data/storage/"$APP_NAME"/wp-content/upgrade
    
    # get wordpress wp-content directory for persistent storage
    cd /tmp
    curl -O https://wordpress.org/latest.tar.gz
    tar xzf latest.tar.gz
    sudo cp -R /tmp/wordpress/wp-content/* /var/lib/dokku/data/storage/"$APP_NAME"/wp-content
    rm -R wordpress
    rm latest.tar.gz
    cd
    
    # change ownership of wp-content
    sudo chown -R 32767:32767 /var/lib/dokku/data/storage/"$APP_NAME"
    
    # mount the folders
    dokku storage:mount "$APP_NAME" /var/lib/dokku/data/storage/"$APP_NAME"/wp-content:/app/wp-content
    
    # setup database
    dokku mariadb:create "$APP_NAME"-database
    dokku mariadb:link "$APP_NAME"-database "$APP_NAME"
    # get and set env vars
    DATABASE_CONNECTION_STRING="$(dokku mariadb:info "$APP_NAME"-database --dsn)"
    DB_PASSWORD=`echo ${DATABASE_CONNECTION_STRING} | sed 's/mysql:\/\/mariadb:\(.*\)@dokku-mariadb-'"$APP_NAME"'-database:3306\/'"$APP_NAME"'_database/\1/'`
    dokku config:set --no-restart "$APP_NAME" DB_NAME="$APP_NAME"_database DB_USER=mariadb DB_PASSWORD="$DB_PASSWORD" DB_HOST=dokku-mariadb-"$APP_NAME"-database DB_PORT=3306
    
    # set salt env vars
    array=( AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT )
    for i in "${array[@]}"
    do
        SALT="$(</dev/urandom tr -dc 'A-Za-z0-9!#$%&()*+,-./:;<=>?@[\]^_`{|}~' | head -c 64 -q)"
        dokku config:set --no-restart "$APP_NAME" "$i"="$SALT"
    done
    
    # set some env vars for cleanup script
    dokku config:set --no-restart "$APP_NAME" isWP=yes hasDB=yes
    
    # restart the app after setting the env vars
    dokku ps:restart "$APP_NAME"
    
    # manually fix upload size
    sudo mkdir /home/dokku/"$APP_NAME"/nginx.conf.d/
    echo 'client_max_body_size 100m;' | sudo tee -a /home/dokku/"$APP_NAME"/nginx.conf.d/upload.conf > /dev/null
    sudo chown dokku:dokku /home/dokku/"$APP_NAME"/nginx.conf.d/upload.conf
    sudo service nginx reload
    
elif [[ ( $IFWP == "n" ) || ( $IFWP == "N" ) || ( $IFWP == "no" ) || ( $IFWP == "No" ) || ( $IFWP == "NO" ) ]];
then
    # do we need a database
    echo "Does this app need a database: (y/n)"
    read IFDB
    
    if [[ ( $IFDB == "y" ) || ( $IFDB == "Y" ) || ( $IFDB == "yes" ) || ( $IFDB == "Yes" ) || ( $IFDB == "YES" ) ]];
    
    then
        # create the app
        dokku apps:exists "$APP_NAME" || dokku apps:create "$APP_NAME"
        
        # setup the domain
        dokku domains:clear "$APP_NAME"
        dokku domains:add "$APP_NAME" "$DOMAIN"
        dokku domains:add "$APP_NAME" www."$DOMAIN"
        dokku domains:remove "$APP_NAME" "$APP_NAME"."$HOSTNAME"
        
        # setup database
        dokku mariadb:create "$APP_NAME"-database
        dokku mariadb:link "$APP_NAME"-database "$APP_NAME"
        # get and set env vars
        DATABASE_CONNECTION_STRING="$(dokku mariadb:info "$APP_NAME"-database --dsn)"
        DB_PASSWORD=`echo ${DATABASE_CONNECTION_STRING} | sed 's/mysql:\/\/mariadb:\(.*\)@dokku-mariadb-'"$APP_NAME"'-database:3306\/'"$APP_NAME"'_database/\1/'`
        dokku config:set "$APP_NAME" DB_NAME="$APP_NAME"_database DB_USER=mariadb DB_PASSWORD="$DB_PASSWORD" DB_HOST=dokku-mariadb-"$APP_NAME"-database DB_PORT=3306
        
        # set some env vars for cleanup
        dokku config:set --no-restart "$APP_NAME" isWP=no hasDB=yes
        
        # restart the app after setting the env vars
        dokku ps:restart "$APP_NAME"
        
    elif [[ ( $IFDB == "n" ) || ( $IFDB == "N" ) || ( $IFDB == "no" ) || ( $IFDB == "No" ) || ( $IFDB == "NO" ) ]];
    then
        # create the app
        dokku apps:exists "$APP_NAME" || dokku apps:create "$APP_NAME"
        
        # setup the domain
        dokku domains:clear "$APP_NAME"
        dokku domains:add "$APP_NAME" "$DOMAIN"
        dokku domains:add "$APP_NAME" www."$DOMAIN"
        dokku domains:remove "$APP_NAME" "$APP_NAME"."$HOSTNAME"
        
        # set some env vars for cleanup
        dokku config:set --no-restart "$APP_NAME" isWP=no hasDB=no
        
        # restart the app after setting the env vars
        dokku ps:restart "$APP_NAME"
        
        echo "Okay, no database."
    fi
else
    echo "Unknown parameter."
fi

echo "All done."

# resources
# https://github.com/dokku-community/dokku-wordpress
# https://gist.github.com/bgallagh3r/2853221
# https://stackoverflow.com/questions/9300950/using-environment-variables-in-wordpress-wp-config
# https://unix.stackexchange.com/questions/230673/how-to-generate-a-random-string
# https://unix.stackexchange.com/questions/45404/why-cant-tr-read-from-dev-urandom-on-osx