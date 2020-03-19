# Dokku Helper Scripts

After creating many many websites on dokku I got tired of the duplication and decided to automate.

<!---
## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.
-->

## Dokku Server

Obviously you'll need a server with the latet Dokku installed. There are many [amazing guides](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-18-04) on [Digital Ocean](https://m.do.co/c/19eed3ad1d11) to setup a decent Ubuntu server. [Dokku installation](http://dokku.viewdocs.io/dokku/getting-started/installation/#1-install-dokku) is also simple.

Digital Ocean even has a [one click Dokku deployment](https://marketplace.digitalocean.com/apps/dokku).

Once your Dokku server is setup you just need to download this repo:

```
git clone git@github.com:mikeydiamonds/dokku-wordpress.git && cd dokku-wordpress
```

Alternatively, you can just download the scripts (`create.sh` and `destroy.sh`) needed for the server. These are bash scripts with no external dependencies:

```
curl -LJO https://raw.githubusercontent.com/mikeydiamonds/dokku-wordpress/master/create.sh
curl -LJO https://raw.githubusercontent.com/mikeydiamonds/dokku-wordpress/master/destroy.sh
```

The scripts may need to be given permission to execute:

```
chmod 755 create.sh destroy.sh
```

Before running the create script verify that you have the required Dokku [MariaDB plugin](https://github.com/dokku/dokku-mariadb.git) installed. You could swap MariaDB for [MySQL](https://github.com/dokku/dokku-mysql) but this is untested. To install the MariaDB plugin:

```
sudo dokku plugin:install https://github.com/dokku/dokku-mariadb.git mariadb
```

And finally run the bash script and answer the questions:

```
./create.sh
```

## Local Wordpress

Along with the server script, I created a bash script to run locally to pull the latest Wordpress but you can use Dokku with any type of app or website. Just review the [plugin list](http://dokku.viewdocs.io/dokku/community/plugins/).

```
cd /to/desired/working/directory
curl -LJO https://raw.githubusercontent.com/mikeydiamonds/dokku-wordpress/master/wordpress-local.sh
chmod 755 wordpress-local.sh
bash wordpress-local.sh
```

### Tricks and Treats

Installing Wordpress with these scripts establishes a series of best practices and works around some of Dokku/Heroku php quirks.

1. With Dokku we already get the benefits of Docker's container separation for apps and databases. This app isolation provides security for apps from other apps on the server.

2. All Wordpress database passwords are stored in environment variables which never leave the server.

3. Wordpress' configuration salts are also stored in env vars and unique values are generating during each app's creation.

4. I also take advantage of Dokku's [peristent storage plugin](http://dokku.viewdocs.io/dokku/advanced-usage/persistent-storage/) so Wordpress' `wp-content` directory is stored outside the container. Docker containers are considered ephemeral and could be deleted or redeployed at anytime. This keeps the unique contents of `wp-content` safe and provides a path for easy backup.

## Tested with

- Ubuntu 18.04 server
- macOS Catalina 10.15 locally

## Help from

- [Dokku's Wordpress plugin](https://github.com/dokku-community/dokku-wordpress)
- [Brian Gallagher's Wordpress Script](https://gist.github.com/bgallagh3r/2853221)
- [Env vars help from StackOverflow](https://stackoverflow.com/questions/9300950/using-environment-variables-in-wordpress-wp-config)
- [Salts help from StackExchange](https://unix.stackexchange.com/questions/230673/how-to-generate-a-random-string)
- [More for the salts that led to the final solution](https://unix.stackexchange.com/questions/45404/why-cant-tr-read-from-dev-urandom-on-osx)

<!---
## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags).
-->

## Authors

- **Mikey Pruitt**

<!---
See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

- Hat tip to anyone whose code was used
- Inspiration
- etc
  -->
