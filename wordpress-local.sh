#!/bin/bash
echo "Enter the app name as it appears on your Dokku server:"
read APP_NAME

echo "What is the remote web server address:"
read SERVER_ADDRESS

WORKDIR=$(pwd)

# make the directory
mkdir "$WORKDIR"/"$APP_NAME"

# get wordpress
cd /Volumes/Macintosh\ HD/Users/Shared/temp
curl -O https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz

# move the files and cleanup
cp -R /Volumes/Macintosh\ HD/Users/Shared/temp/wordpress/ "$WORKDIR"/"$APP_NAME"
rm -R wordpress
rm -R latest.tar.gz

# work with the new files
cd "$WORKDIR"/"$APP_NAME"
rm -R wp-content
rm -R wp-config-sample.php

# get the extra dokku files from github
curl -LJO https://raw.githubusercontent.com/mikeydiamonds/dokku-wordpress/master/.gitignore
curl -LJO https://raw.githubusercontent.com/mikeydiamonds/dokku-wordpress/master/.user.ini
curl -LJO https://raw.githubusercontent.com/mikeydiamonds/dokku-wordpress/master/Procfile
curl -LJO https://raw.githubusercontent.com/mikeydiamonds/dokku-wordpress/master/composer.json
curl -LJO https://raw.githubusercontent.com/mikeydiamonds/dokku-wordpress/master/nginx.conf
curl -LJO https://raw.githubusercontent.com/mikeydiamonds/dokku-wordpress/master/php.ini
curl -LJO https://raw.githubusercontent.com/mikeydiamonds/dokku-wordpress/master/wp-config.php

# composer build
composer update

# git setup and push
git init
git add .
git commit -m 'initial commit'
git remote add dokku dokku@"$SERVER_ADDRESS":"$APP_NAME"

# push to web server
git push dokku master

# open the files in vs code if installed
command -v code . >/dev/null 2>&1 || { echo >&2 "No VS Code? Shame!"; exit 1; }

# future - add this snippet to functions.php

# /**
#  * Stop System Update emails
# */

# add_filter( 'auto_core_update_send_email', 'wpb_stop_auto_update_emails', 10, 4 );

# function wpb_stop_update_emails( $send, $type, $core_update, $result ) {
# if ( ! empty( $type ) && $type == 'success' ) {
# return false;
# }
# return true;
# }