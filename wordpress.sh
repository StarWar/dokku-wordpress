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

# restart the app after setting the env vars
dokku ps:restart "$APP_NAME"

# resources
# https://github.com/dokku-community/dokku-wordpress
# https://gist.github.com/bgallagh3r/2853221
# https://stackoverflow.com/questions/9300950/using-environment-variables-in-wordpress-wp-config
# https://unix.stackexchange.com/questions/230673/how-to-generate-a-random-string
# https://unix.stackexchange.com/questions/45404/why-cant-tr-read-from-dev-urandom-on-osx