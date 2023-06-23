The problem
===========

After a while **when using ./manage.py runserver**,
Postgresql is "crashing" : it does not accept connections anymore.
It gives this message::

    FATAL: remaining connection slots are reserved for non-replication superuser connections

To reproduce
============

Postgresql installation
------------------------

Run this::

    # Create the file repository configuration:
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

    # Import the repository signing key:
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

    # Update the package lists:
    sudo apt-get update

    # Install the latest version of PostgreSQL.
    # If you want a specific version, use 'postgresql-15' or similar instead of 'postgresql':
    sudo apt-get -y install postgresql-15 postgresql-contrib




Postgresql configuration
------------------------

As portgres user (replace `ddtb_debug` by the appropriate database name)::

    # psql

    postgres=# create database ddtb_debug;
    postgres=# create user www with encrypted password 'xxx';
    postgres=# grant all privileges on database ddtb_debug to www;
    postgres=# GRANT SET ON PARAMETER session_replication_role TO www;
    postgres=# \c ddtb_debug;
    ddtb_debug=# grant usage, create on schema public to www;


As root (to gain access postgres via login/passwd for Djano)::

    # sed -i 's,local.*all.*all.*peer,local    all     all     md5,' /etc/postgresql/15/main/pg_hba.conf
    # service postgresql restart

Python envionment installation
------------------------------

As user:

Install Poetry::

    curl -sSL https://install.python-poetry.org | python3 -

Install Packages::

    cd ~/projects/ddtb-debug
    poetry install

Database init
-------------

As user::

Create the config file ~/.config/ddtb.toml with your database informations::

    [databases.default]
    name = "ddtb_debug"
    user = "www"
    password = "your password"

I modified ``settings.py`` to read that file.

Migrate and create superuser::

    cd ~/projects/ddtb-debug
    poetry shell
    ./manage.py migrate

    # create an admin user :
    ./manage.py createsuperuser

The minimal project is the beginning of the example given by Django team : the polls

You will need to go to django admin to create some question::

    poetry shell
    ./manage.py runserver

Then goto `http://localhost:8000/admin/polls/question/`_ to fill-in some question.
They will be accessible from `http://localhost:8000/polls/`_ (that will be the test URL)

You can know maximum connections allowed
and follow the postgresql connection count ths way::

    sudo -i
    su - postgresql
    psql

    SHOW max_connections;
    SELECT count(*) AS total_connections FROM pg_stat_activity;

If not done yet, install Apache benchmark::

    sudo apt install apache2-utils

``max_connections`` is usually set to 100, so start requesting 200 pages::

    ab -n 200 http://localhost:8000/polls/

You should encounter the problem in the runserver window
