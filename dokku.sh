#!/bin/bash
echo "Enter the new app name:"
read APP_NAME

# create the app
dokku apps:exists "$APP_NAME" || dokku apps:create "$APP_NAME"

# setup the domain
echo "Enter the apps domain name:"
read DOMAIN
dokku domains:clear "$APP_NAME"
dokku domains:add "$APP_NAME" "$DOMAIN"
dokku domains:add "$APP_NAME" www."$DOMAIN"
dokku domains:remove "$APP_NAME" "$APP_NAME"."$HOSTNAME"

# do we need a database
echo "Does this app need a database: (y/n)"
read IFDB

if [[ ( $IFDB == "y" ) || ( $IFDB == "Y" ) || ( $IFDB == "yes" ) ]];
# if [ "$IFDB" = "y" ] || [ "$IFDB" = "Y" ] || [ "$IFDB" = "yes" ];
then
    # setup database
    dokku mariadb:create "$APP_NAME"-database
    dokku mariadb:link "$APP_NAME"-database "$APP_NAME"
    # get and set env vars
    DATABASE_CONNECTION_STRING="$(dokku mariadb:info "$APP_NAME"-database --dsn)"
    DB_PASSWORD=`echo ${DATABASE_CONNECTION_STRING} | sed 's/mysql:\/\/mariadb:\(.*\)@dokku-mariadb-'"$APP_NAME"'-database:3306\/'"$APP_NAME"'_database/\1/'`
    dokku config:set "$APP_NAME" DB_NAME="$APP_NAME"_database DB_USER=mariadb DB_PASSWORD="$DB_PASSWORD" DB_HOST=dokku-mariadb-"$APP_NAME"-database DB_PORT=3306
fi
