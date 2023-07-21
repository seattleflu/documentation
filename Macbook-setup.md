# Mac - new system setup instructions

These instructions describe software installations for MacOS as of 6/24/2021 and are based on an Intel-based Mac running Big Sur (macOS v11.4). Any problems with this process may result from a different architecture, OS version, or newer versions of the software being installed.

_Note: MacOS uses Z shell (zsh) as the default shell. If you prefer bash, you can make that the default shell under System Preferences > Users and Groups (unlock the lock icon to make changes) > right click your user, select 'Advanced Options' and change 'Login shell' to /bin/bash. Alternatively, you can set your default shell to bash using `chsh -s /bin/bash`. If using bash add `export BASH_SILENCE_DEPRECATION_WARNING=1` to ~/.bashrc or ~/.bash_profile and continue to update that same file instead of ~/.zshrc throughout this setup._

## Download and install the following software:
 - [Slack](https://slack.com/downloads/mac)
 - [Zoom](https://zoom.us/download)
 - [OneDrive](https://www.microsoft.com/en-us/microsoft-365/onedrive/download)*
 - Web browser, such as [Chrome](https://www.google.com/chrome/)*
 - [LastPass browser extension](https://lastpass.com/misc_download2.php)
 - Text editor, such as [VSCode](https://code.visualstudio.com/download)
 - [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html)
 - [Postgres.app](https://postgresapp.com/downloads.html) (get "Postgres.app with all currently supported versions" - we are currently running v10.x in production)
 - [pgAdmin4](https://www.pgadmin.org/download/)

\* _may already be installed by UW IT_

---
## Install Homebrew 

Follow the Homebrew installation instructions [here](https://docs.brew.sh/Installation).

---
## Install Python 3.6.9 via pyenv

At time of writing, MacOS ships with Python 2.7.16 (/usr/bin/python) and Python 3.8.2 (/usr/bin/python3). We will leave these installed but will not use them, instead opting for pyenv to manage python versions (starting with Python 3.6.9 to match current production server).

```
brew install zlib sqlite bzip2 libiconv libzip xz pyenv 
LDFLAGS="-L$(brew --prefix zlib)/lib -L$(brew --prefix bzip2)/lib" CPPFLAGS="-I$(brew --prefix xz)/include" pyenv install --patch 3.6.9 < <(curl -sSL https://github.com/python/cpython/commit/8ea6353.patch\?full_index\=1)
```

Add the following line to ~/.zshrc:
```
export PATH=/Users/<your system username>/.pyenv/versions/3.6.9/bin:$PATH
```
Then restart terminal. Now `python --version` and `python3 --version` should show version 3.6.9.

Next install pipenv and envdir:
```
pip install pipenv envdir
```

### UPDATE: install Python 3.9.10

Production system was upgraded to Python 3.9.10 on 2/8/2022. To install Python 3.9.10 using pyenv, and make it your default version:
```
pyenv install 3.9.10
```

Add the following (or replace existing) line in ~/.zshrc:
```
export PATH=/Users/<your system username>/.pyenv/versions/3.9.10/bin:$PATH
```
Then restart terminal. Now `python --version` and `python3 --version` should show version 3.9.10.

Next install pipenv and envdir:
```
pip install pipenv envdir
```

---
## Install updated version of bash

At time of writing, MacOS ships with bash version 3.x. A newer version is required to run some of our bash scripts, so we install bash 5.x with Homebrew:
```
brew install bash
```
Close are restart terminal and check bash version 5.x is working. (Note: Homebrew installs bash 5.x to /usr/local/bin/bash. bash 3.x is still installed at /bin/bash)
```
bash --version
```

---
## Create a PostgreSQL 13 instance using Postgres.app

1. Launch Postgres from Applications folder. 
2. Click the show panel button in the bottom left corner.
3. Click the + button to add a new PostgreSQL instance.
4. Name the new instance and select version 13 from the dropdown. Leave port as 5432.
5. Press 'Create Server' button.
6. Optionally, under 'Server Settings' press 'Change password' and set a password. If you do set a password, be sure to add it to your .pgpass file, covered later in this document.
7. Press 'Initialize' to start the server.

You should now have a PostgreSQL server running with these default settings:
- Host: localhost
- Port: 5432
- User: _your system username_
- Database: _same as user_
- Password: _none_

## Add Postgres 13 binary folder to PATH

Add the following line to ~/.zshrc:
```
export PATH=$PATH:/Applications/Postgres.app/Contents/versions/13/bin
```
Then close and restart terminal. You should now be able to run psql from anywhere.
```
psql --version
```

---
## Block specific git commands

To prevent inadvertantly adding and commiting files, the commands `git add .` and `git stage .` should be avoided. This can be enforced by adding a wrapper on the git command to your ~/.zshrc file:

```
git() {
    if [ "$1" = "add" -o "$1" = "stage" ]; then
        if [ "$2" = "." ]; then
            printf "'git %s .' is currently disabled by your Git wrapper.\n" "$1";
        else
            command git "$@";
        fi
    else
        command git "$@";
    fi;
}
```

Test that the wrapper is working by opening a new terminal and running those two commands from any folder.

## Install git-secrets

Similar to above, install the [git-secrets](https://github.com/awslabs/git-secrets) as a tool to avoid accidentally checking secrets into git. 

Install using homebrew: 
```
brew install git-secrets
```

From the [advanced configuration](https://github.com/awslabs/git-secrets#advanced-configuration), configure the secrets checks for AWS credentials in existing repos and those cloned in the future: 
```
git secrets --register-aws --global
git secrets --install ~/.git-templates/git-secrets
git config --global init.templateDir ~/.git-templates/git-secrets
```

---
## Clone git repos

Create a workspace (e.g. ~/workspace/seattleflu) and clone the three primary repos:
```
mkdir ~/workspace
mkdir ~/workspace/seattleflu
cd ~/workspace/seattleflu
git clone https://github.com/seattleflu/id3c
git clone https://github.com/seattleflu/id3c-customizations
git clone https://github.com/seattleflu/backoffice
```

Make sure you can run `pipenv sync` in the id3c and id3c-customizations folders:
```
cd ~/workspace/seattleflu/id3c
pipenv sync
pipenv run pytest -v
pipenv run id3c --help
```

```
cd ~/workspace/seattleflu/id3c-customizations
pipenv sync
pipenv run pytest -v
```

---
## Create a local environment variables directory

We use envdir for managing environment variables. You can set up an env.d directory locally. It will contain individual files for every environment variable, and subdirectories to further organize. You can see one example for the organizational structure in [backoffice/id3c-production/env.d](https://github.com/seattleflu/backoffice/tree/master/id3c-production/env.d). 

Create an env.d directory in the same folder:
```
mkdir ~/workspace/seattleflu/env.d
```

For this example we'll create a redcap subdirectory containing two environment variables:
```
mkdir ~/workspace/seattleflu/env.d/redcap
```

Use a text editor to create a new file ~/workspace/seattleflu/env.d/redcap/REDCAP_API_URL with contents:
```
https://redcap.iths.org/api/
```

We store Redcap API tokens using this file naming convention: REDCAP_API_TOKEN_redcap.iths.org_{PROJECT_ID}. 

Log in to the REDCap instance, open a specific project, note the project ID (pid) value in the URL, and click "API" from in the sidebar menu. Generate an API token and save the value in a new file ~/workspace/seattleflu/env.d/redcap/REDCAP_API_TOKEN_redcap.iths.org_{PROJECT_ID}

_Note: These environment variable files and others can be added later as you need them._

---
## Create a local copy of the database

This is an expanded version of the documentation found [here](https://github.com/seattleflu/backoffice/tree/master/dev#refresh-database)

Add PGHOST and PGUSER to ~/.zshrc:
```
export PGHOST=localhost
export PGUSER=<your system username>
```
Then close and restart terminal.

Please note that this process can take several hours and is best to run with a fast connection and with battery saving options turned off in System Preferences > Battery > Power Adapter (check "Prevent computer from sleeping automatically when the display is off")

We create a local directory to save the pg_dump files, and specify bash on the refresh-database command to ensure it uses bash 5.x:
```
mkdir ~/workspace/refresh-db-workdir
cd ~/workspace/seattleflu/backoffice
bash ./dev/refresh-database -d ~/workspace/refresh-db-workdir -x
```
> Note: If you use the same working directory to update the database you should empty it before refreshing again. If you don't clear the directory, this command will utilize the database dump that already exists rather than new production data.
---
## Create Postgres Service and Password files

Follow [these instructions](https://github.com/seattleflu/id3c#connection-details) to create and test Postgres service and password files.

---
## Install sqitch

[Sqitch](http://sqitch.org/) is a database change management application.
```
brew tap sqitchers/sqitch
brew install sqitch --with-postgres-support
```

## Smartystreets and Geocoding cache files

ID3C uses Smartystreets for geocoding addresses. Credentials must be provided, and can be added to a new env.d folder:
```
mkdir ~/workspace/seattleflu/env.d/smartystreets
```
Use a text editor to create new files ~/workspace/seattleflu/env.d/smartystreets/SMARTYSTREETS_AUTH_ID and SMARTYSTREETS_AUTH_TOKEN. Those values can be found in tne LastPass shared folder.

Each address geocoded incurs a cost so the production server uses cache files to minimize the number of geocoding service requests. To avoid charges when running `id3c etl redcap-det` commands locally, these cache files should be copied from the production server to your local machine:
```
mkdir ~/workspace/seattleflu/cache
scp -i [ssh_key_file].pem ubuntu@backoffice.seattleflu.org:/home/ubuntu/sfs-cache.pickle ~/workspace/seattleflu/cache/sfs-cache.pickle
scp -i [ssh_key_file].pem ubuntu@backoffice.seattleflu.org:/home/ubuntu/scan-cache.pickle ~/workspace/seattleflu/cache/scan-cache.pickle
scp -i [ssh_key_file].pem ubuntu@backoffice.seattleflu.org:/home/ubuntu/uw-reopening-cache.pickle ~/workspace/seattleflu/cache/uw-reopening-cache.pickle
```

To determine which cache file to use with which `id3c etl redcap-det` project argument, refer to the [backoffice crontab file](https://github.com/seattleflu/backoffice/blob/master/crontabs/id3c-production).

## Create public and private ssh keys

These keys will be used to access private Github repos and ssh to the backoffice server.

Follow [these instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/about-ssh) to generate your keys and update your Github account with your public key. Your public key will also need to be added to the backoffice server so that you can use connect via ssh.

