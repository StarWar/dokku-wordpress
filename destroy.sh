#!/bin/bash

# show the app list
dokku apps:list

echo "Enter the app name you would like to destroy:"
read APP_NAME

# get $isWP and $hasDB env vars
isWP="$(dokku config:get "$APP_NAME" isWP)"
hasDB="$(dokku config:get "$APP_NAME" hasDB)"

if [[ ( $isWP == "yes" ) && ( $hasDB == "yes" ) ]];

then
    # destroy nginx's upload.conf
    sudo rm -R /home/dokku/"$APP_NAME"/nginx.conf.d
    
    # destroy app and database
    dokku --force apps:destroy "$APP_NAME"
    dokku --force mariadb:destroy "$APP_NAME"-database
    
    # destroy persistent storage directories
    sudo rm -R /var/lib/dokku/data/storage/"$APP_NAME"
    
elif [[ ( $isWP == "no" ) && ( $hasDB == "yes" ) ]];
then
    # destroy nginx's upload.conf
    sudo rm -R /home/dokku/"$APP_NAME"/nginx.conf.d
    
    # destroy app and database
    dokku --force apps:destroy "$APP_NAME"
    dokku --force mariadb:destroy "$APP_NAME"-database
    
else
    dokku --force apps:destroy "$APP_NAME"
fi

echo $APP_NAME" destroyed."