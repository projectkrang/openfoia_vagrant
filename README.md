# ProjectKrang Vagrant Box
This box contains all the commands and data for an automated setup of Krang, [openFOIA's FOIA document storage and search engine](https://github.com/projectkrang/foia-hub). The automated setup includes provisions for installing, starting, migrating, and populating both Postgres and Elasticsearch.

# Getting Started

Make sure you have `vagrant` installed. For instance, on OS X with Homebrew:

```
$ brew install caskroom/cask/brew-cask
$ brew cask install vagrant
```

Then, ensure you have the appropriate Vagrant Box installed:

```
$ vagrant box add ubuntu/trusty32
```

Make sure that this repo is cloned in the directory above the foia-hub repo. The directory structure should look like this.
```
README.md
Vagrantfile
foia-hub/
provision/
```

You can get started with development by running the `Vagrantfile`:
```
$ vagrant up
```

This will provision an entire setup for you slowly (see `provision/dev/bootstrap.sh`). You can access Django and start `runserver` by doing the following:
```
$ vagrant ssh
$ python manage.py runserver 0.0.0.0:8000
```

You can then access the site from your web browser by going to `http://192.168.19.61:8000/`

To suspend Vagrant while not in use.
```
vagrant suspend
```
