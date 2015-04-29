#!/usr/bin/env bash

sudo apt-get update -y
sudo apt-get install python-pip -y
sudo apt-get install git -y

sudo apt-get install libevent-dev -y
sudo apt-get install libpq-dev -y
sudo apt-get install python-virtualenv -y
sudo apt-get install python-dev -y
sudo apt-get install libbz2-dev -y
sudo apt-get install libsqlite3-dev -y
sudo apt-get install libreadline-dev -y
sudo apt-get install -y build-essential

sudo apt-get install -y postgresql postgresql-contrib

sudo apt-get install -y default-jdk
wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
echo 'deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main' | sudo tee /etc/apt/sources.list.d/elasticsearch.list
sudo apt-get update
sudo apt-get -y install elasticsearch=1.4.4



sudo su vagrant <<'EOF'
export USE_HTTPS=True
curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bash_profile
. ~/.bash_profile
pyenv install 3.4.1
pyenv rehash
pyenv virtualenv 3.4.1 krang
pyenv rehash
pyenv activate krang

echo 'Installing Requirments'
pip install -r /vagrant/foia-hub/requirements.txt
pip install -r /vagrant/foia-hub/requirements-dev.txt
cd /vagrant/foia-hub

echo 'Creating Database'
sudo -u postgres createdb foia
sudo -u postgres psql -d foia -c "CREATE USER foia WITH PASSWORD 'foia';"

echo 'Setting up env vars'
export DATABASE_URL="postgres://foia:foia@localhost:5432/foia"
export FOIA_SECRET_SESSION_KEY="CHANGE THIS"
export DJANGO_SETTINGS_MODULE=foia_hub.settings.dev

echo 'Setting commands to run on startup'
echo 'cd /vagrant/foia-hub' >> ~/.bash_profile
echo 'pyenv activate krang' >> ~/.bash_profile
echo 'export DATABASE_URL="postgres://foia:foia@localhost:5432/foia"' >> ~/.bash_profile
echo 'export DJANGO_SETTINGS_MODULE=foia_hub.settings.dev' >> ~/.bash_profile
echo 'export FOIA_SECRET_SESSION_KEY="CHANGE THIS"' >> ~/.bash_profile
sudo service elasticsearch restart
echo 'sudo service elasticsearch restart & sleep 15' >> ~/.bash_profile

echo 'Migrating database and loading contacts'
python manage.py migrate
echo 'python manage.py migrate' >> ~/.bash_profile
python manage.py load_agency_contacts

echo 'Loading doc data and ensuring that data is reloaded on startup'
python manage.py loaddata ../provision/dev/docusearch.json
echo 'python manage.py loaddata ../provision/dev/docusearch.json
' >> ~/.bash_profile

echo 'Reindexing database and forcing reindex on load'
python manage.py rebuild_index --noinput
echo 'python manage.py rebuild_index --noinput' >> ~/.bash_profile
EOF
