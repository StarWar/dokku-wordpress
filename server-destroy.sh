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
    # destroy app and database
    dokku --force apps:destroy "$APP_NAME"
    dokku --force mariadb:destroy "$APP_NAME"-database
    
    # destroy persistent storage directories
    sudo rm -R /var/lib/dokku/data/storage/"$APP_NAME"
    
elif [[ ( $isWP == "no" ) && ( $hasDB == "yes" ) ]];
then
    # destroy app and database
    dokku --force apps:destroy "$APP_NAME"
    dokku --force mariadb:destroy "$APP_NAME"-database
    
else
    dokku --force apps:destroy "$APP_NAME"
fi

echo $APP_NAME" destroyed."

# resources
# https://github.com/dokku-community/dokku-wordpress
# https://gist.github.com/bgallagh3r/2853221
# https://stackoverflow.com/questions/9300950/using-environment-variables-in-wordpress-wp-config
# https://unix.stackexchange.com/questions/230673/how-to-generate-a-random-string
# https://unix.stackexchange.com/questions/45404/why-cant-tr-read-from-dev-urandom-on-osx