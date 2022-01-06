- [Service overview](#service-overview)
  - [uWSGI apps](#uwsgi-apps)
  - [systemd apps](#systemd-apps)
- [Recurring deployments](#recurring-deployments)
  - [Deploying id3c or id3c-customizations](#deploying-id3c-or-id3c-customizations)
    - [Prerequisites](#prerequisites)
    - [Steps for deployment:](#steps-for-deployment)
      - [Schema changes to the database](#schema-changes-to-the-database)
      - [Code changes to id3c](#code-changes-to-id3c)
      - [Data uploads to the database](#data-uploads-to-the-database)
  - [Deploying husky-musher](#deploying-husky-musher)
  - [Deploying scan-switchboard](#deploying-scan-switchboard)
  - [Deploying specimen-manifests](#deploying-specimen-manifests)
  - [Deploying backoffice-apache2](#deploying-backoffice-apache2)
- [Initial deployments](#initial-deployments)


## Service overview
We currently use two hosting services for our production applications: uWSGI and systemd.

### uWSGI apps
* [id3c-production web API](https://github.com/seattleflu/backoffice/tree/master/id3c-production)
* [Husky Musher](https://github.com/seattleflu/backoffice/tree/master/husky-musher)

### systemd apps
* [Metabase](https://github.com/seattleflu/backoffice/tree/master/metabase)
* [Lab Labels](https://github.com/seattleflu/backoffice/tree/master/lab-labels)
* [SCAN Switchboard](https://github.com/seattleflu/backoffice/tree/master/scan-switchboard)


## Recurring deployments
### Deploying id3c or id3c-customizations
* [id3c] source code
* [id3c-customizations] source code
#### Prerequisites
Before you get started, you'll need the following:

* a personal admin account to the production ID3C database plus the login information for the `postgres` user account.
* a configured `sqitch` environment on your local machine.
  > See [Infrastructure] → **Databases (PostgreSQL)** → [sqitch configuration]
* a public key shared with the `ubuntu` account on `backoffice.seattleflu.org`.

#### Steps for deployment:
1. Merge code changes in [id3c] or [id3c-customizations] to each master branch, respectively.
2. Run `pipenv update` in the `id3c-production` directory of your [backoffice]
   checkout.  This will lock ID3C and our customizations at the latest state of
   their master branch on GitHub.  Review, commit, and push the changes.

##### Schema changes to the database
> If you have no schema changes to deploy, you may skip this section.
3. Deploy database schema changes via `sqitch` from your local machine.

   _**Note:**_ The "refresh-materialized-shipping-views" cronjob locks the shipping views and can cause a delay in the deployment of sqitch changes.
   Consider commenting out this cronjob on the `backoffice` server before deploying sqitch changes for shipping views.

   Run the following commands, replacing the curly-bracketed text with your specifications.

   First, check that the plan looks good.

        PGUSER={your-admin-username} sqitch status {database name}

   > Tip: check `~/.pg_service.conf` for your admin username and other connection details

   If everything looks good, run the following **using the `postgres` user**.

        PGUSER=postgres sqitch deploy {database name}

3. Grant any newly needed roles to the `backoffice` database automation user via

        PGUSER={your-admin-username} PGSERVICE={service name} psql

   Once inside of the `psql` prompt, run:

        grant "{role}" to "backoffice-etl";


##### Code changes to id3c
> If you have no code changes to deploy, you may skip this section.

4. Log onto the `backoffice` server.
5. Navigate to the `/opt/backoffice` directory and run `git pull`.
6. Add any newly needed secret environment variables under `id3c-production/env.d/…`.
   (Non-secret environment variables should be committed and pulled in via git.)
7. Install the latest production environment with `(cd id3c-production; pipenv sync)`.
8. Install the latest crontabs with `sudo make -C crontabs`.
   Check the crontabs were successfully installed by inspecting `/var/log/syslog`.
   Look out for errors such as:
   ```
   cron[901]: Error: bad minute; while reading /etc/cron.d/backoffice-id3c-production
   cron[901]: (*system*backoffice-id3c-production) ERROR (Syntax error, this crontab file will be ignored)
   ```
9. Reload the web API backend by running `sudo systemctl reload uwsgi@api-production`.
   > See the uWSGI documentation under [Infrastructure] → **Hosts** → [backoffice.seattleflu.org]
5. Check the service status by running `sudo systemctl status uwsgi@api-production`.
10. Check web API log file with `sudo journalctl -fu uwsgi@api-production`.


##### Data uploads to the database
> If you have no data to upload, you may skip this section.

10. Upload data to the `receiving` area of the database from your local machine.
    Run the desired `id3c` command(s) with a prefix of `PGSERVICE={service name}`.


### Deploying husky-musher
* [husky-musher] source code

1. Log onto the `backoffice` server.
2. Navigate to the `/opt/husky-musher` directory and run `git pull`.
3. Install the latest code with `pipenv sync`.
4. Reload the uWSGI server by running `sudo systemctl reload uwsgi@husky-musher`.
   > See the uWSGI documentation under [Infrastructure] → **Hosts** → [backoffice.seattleflu.org]
5. Check the uWSGI server status by running `sudo systemctl status uwsgi@husky-musher`.
6. Check log file with `sudo journalctl -fu uwsgi@husky-musher` for any errors or warnings.


### Deploying scan-switchboard
* [scan-switchboard] source code

1. Log onto the `backoffice` server.
2. Navigate to the `/opt/scan-switchboard` directory and run `git pull`.
3. Add any newly needed secret environment variables under `/opt/backoffice/id3c-production/env.d/…`.
   (Non-secret environment variables should be committed and pulled in via git.)
4. Install the latest code with `./bin/venv-run pip-sync`.
5. If you've changed the structure of the `record_barcodes` table in the SQLite database, delete the old database file under `data/`.
6. Restart scan-switchboard with `sudo systemctl restart scan-switchboard`

There is a crontab that syncs the switchboard. If you have changed something in scan-switchboard that needs accompanying changes to the crontab, make that change in the backoffice repository and deploy that too.


### Deploying specimen-manifests
* [specimen-manifests] source code

1. Log onto the `backoffice` server.
2. Navigate to the `/opt/specimen-manifests` directory and run `git pull`.


### Deploying backoffice-apache2
* [backoffice-apache2] source code (private)

1. Log onto the `backoffice` server with agent forwarding:
   ```
   eval `ssh-agent`
   ssh-add ~/.ssh/id_rsa
   ssh -A ubuntu@backoffice.seattleflu.org
   ```
2. Navigate to the `/etc/apache2` directory and run `sudo git pull`.
3. Reload apache by running: `sudo systemctl reload apache2`.


## Initial deployments
Note: these deployment steps assume you're using Pipenv for dependency management.

1. With `{app-name}` as your desired application name, clone your new repo on the backoffice server under `/opt/{app-name}`.
   This should ideally match the name of the GitHub repository.
2. Decide whether the app should be hosted as a uWSGI or systemd service. ASGI apps (like [scan-switchboard] cannot use uWSGI).
3. Update the (private) [backoffice-apache2] repo.
   Replacing `{desired-endpoint}` with the desired URL endpoint at https://backoffice.seattleflu.org/ where you want your app to be available, make the following changes:
   * **uWSGI workflow:**
     1. make sure that the application is available via a variable named `application`.
     2. Update the [backoffice apache2 le ssl conf file] to add a new `ProxyPass` entry for the app:
         ```apache
         ProxyPass /{desired-endpoint} unix:/run/uwsgi/app/{desired-endpoint}/socket|uwsgi://{desired-endpoint}/
         ```
        * If you want a Shibboleth UW NetID authentication layer, add the following to give access to anyone with a valid UW NetID:
            ```apache
            <Location "/{desired-endpoint}">
               # Authenticate visitors with Shibboleth (configured elsewhere to use
               # UW's IdP).  Any valid UW NetID will do, so all we need is a valid
               # Shibboleth session.
               AuthType shibboleth
               Require shib-session

               # Tell Shibboleth that it should always try to establish a session if
               # none exists, otherwise it might decide not to and the Require rule
               # above would prevent access.
               ShibRequestSetting requireSession 1
            </Location>
            ```
         * If instead you want to restrict UW NetID access to limited NetIDs, instead use
            ```apache
            <Location "/{desired-endpoint}">
               # Authenticate visitors with Shibboleth (configured elsewhere to use
               # UW's IdP).  Require a UW NetID in one of our predefined groups.
               AuthType shibboleth
               AuthGroupFile authorized-users
               Require group {space-separated group-names}

               # Tell Shibboleth that it should always try to establish a session if
               # none exists, otherwise it might decide not to and the Require rule
               # above would prevent access.
               ShibRequestSetting requireSession 1
            </Location>
            ```
            The given `AuthGroupFile` should live in the top-level of the (private) [backoffice-apache2] repo.
            Each specified group name should be declared inside the given `AuthGroupFile` file with the following syntax:
            ```
            {group-name}: {netid}@washington.edu {netid}@washington.edu ...
            ```

            (See an example of the [authorized NetIDs](https://github.com/seattleflu/backoffice-apache2/blob/master/authorized-users)).

   * **systemd workflow:**
      1. Update the [backoffice apache2 le ssl conf file] to add the following entries for the app. Note that our convention for a new `{port-number}` has been to start at `3000` and increment by one for each new application.
         ```apache
         ProxyPass /{desired-endpoint}/ http://localhost:{port-number}/
         ProxyPassReverse /{desired-endpoint}/ http://localhost:{port-number}/
         RedirectMatch /{desired-endpoint}$ /{desired-endpoint}/
         ```

4. [Deploy your apache2 changes](#deploying-backoffice-apache2) from the previous step.
5. With `{app-name}` as your desired application name, create a new directory in the [backoffice] repo named `{app-name}`, and add the following to it:
   * A README.
   * **uWSGI workflow:**
     * A `uwsgi.ini` file that contains:
         ```ini
         #
         # This uWSGI configuration file should be used by referencing it from Ubuntu's
         # app-based configuration layout.
         #
         # Put the following in /etc/uwsgi/apps-available/{app-name}.ini:
         #
         #    [uwsgi]
         #    ini = /opt/backoffice/{app-name}/uwsgi.ini
         #
         # and make a symlink to it from /etc/uwsgi/apps-enabled/{app-name}.ini.
         #
         # It is assumed that Pipenv is configured to install its virtualenvs in .venv
         # with PIPENV_VENV_IN_PROJECT=1.
         #
         [uwsgi]
         plugin = python3
         envdir = %d/env.d/uwsgi
         virtualenv = /opt/{app-name}/.venv
         wsgi-file = /opt/{app-name}/app.py
         processes = 1
         threads = 2
         enable-threads = true
         ```
         See the [husky-musher uwsgi.ini file](https://github.com/seattleflu/backoffice/blob/master/husky-musher/uwsgi.ini) as an example.
         You may want to choose a different number of processes and threads than what is used in the example above.
     * A new envdir diretory at `env.d/uwsgi`.
     Inside it, add the non-sensitive environment variables.

   * **systemd workflow:**
     * A `Makefile` that contains:
         ```make
         SHELL := /bin/bash -euo pipefail

         apps := \
            {app-name}.service

         install: $(apps:%=/etc/systemd/system/%)

         /etc/systemd/system/%: %
            @install -cv $< $@
         ```
         See the [scan-switchboard Makefile](https://github.com/seattleflu/backoffice/blob/master/scan-switchboard/Makefile) as an example.
     * A systemd service file named `{app-name}.service` that contains:
         ```ini
         [Unit]
         Description=My new app!
         After=network.target

         [Service]
         WorkingDirectory=/opt/{app-name}
         User=nobody
         Environment="PIPENV_VENV_IN_PROJECT=1"
         ExecStart=/usr/local/bin/pipenv run ./bin/serve --config base_url:/{desired-endpoint}/
         Restart=always
         RestartSec=10

         [Install]
         WantedBy=default.target
         ```
         See the [SCAN Switchboard service file](https://github.com/seattleflu/backoffice/blob/master/scan-switchboard/scan-switchboard.service) as an example.

6. Update [backoffice] repo documentation README pointing to the newly created directory from the previous step.
7. Deploy the [backoffice] repo changes.
   1. From the `/opt/backoffice` directory on the backoffice server, run `git pull`.
   2. Add any secret environment variables under `/opt/backoffice/{app-name}/env.d/`.
8. Deploy your app for the first time.
   With `{app-name}` as your desired application name:
   * **uWSGI workflow:**
     1. On the backoffice server, put the following in `/etc/uwsgi/apps-available/{app-name}.ini`:
         ```ini
         [uwsgi]
         ini = /opt/backoffice/{app-name}/uwsgi.ini
         ```
         and make a symlink to it from `/etc/uwsgi/apps-enabled/{app-name}.ini`.
     2. Explicitly grant the www-data user permissions to see the uwsgi envdir with:
        * `chgrp -R www-data /opt/backoffice/*/env.d/uwsgi`
        * `chmod -R g=rX /opt/backoffice/*/env.d/uwsgi`

   * **systemd workflow:**
     1. Inside `/opt/backoffice/`, run `sudo make -C {app-name}`.
     2. To deploy the app, run `sudo systemctl daemon-reload`.
     3. Then, run `sudo systemctl enable {app-name}`.
        This command creates a symlink pointing from `/etc/systemd/system/default.target.wants/{app-name}.service` → `/etc/systemd/system/{app-name}.service`.
     4. Next, start the service via `sudo systemctl start {app-name}`.

9.  Update the [recurring deployments documentation](#recurring-deployments) on how to update this app in the future.
10. Update [infrastructure documentation](infrastructure#backoffice-seattleflu.org) to add information about your new uWSGI or systemd app.


[backoffice-apache2]: https://github.com/seattleflu/backoffice-apache2
[backoffice apache2 le ssl conf file]: https://github.com/seattleflu/backoffice-apache2/blob/master/sites-available/backoffice-le-ssl.conf
[Infrastructure]: infrastructure
[backoffice]: https://github.com/seattleflu/backoffice
[ID3C]: https://github.com/seattleflu/id3c
[ID3C-customizations]: https://github.com/seattleflu/id3c-customizations
[backoffice.seattleflu.org]: infrastructure#backofficeseattlefluorg
[sqitch configuration]: infrastructure#sqitch-configuration
[Pipenv]:https://pipenv.readthedocs.io/en/latest/
[specimen-manifests]:https://github.com/seattleflu/specimen-manifests
[husky-musher]: https://github.com/seattleflu/husky-musher
[scan-switchboard]: https://github.com/seattleflu/scan-switchboard
