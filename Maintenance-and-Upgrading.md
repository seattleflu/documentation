# Upgrading the Software Stack

From time to time it will become necessary to update various parts of the software stack in order to address security vulnerabilities and keep everything in the upstream support cycle.

## Upgrading Python
The upstream Python support cycle, including end-of-life dates, can be found here: https://devguide.python.org/#branchstatus

Currently we use Ubuntu 18.04 LTS's system Python (v3.6.9), which is not best-practice, and the Python community has alread end-of-lifed it. The next update will see us switch to Python 3.9, building it from source.

We will manage Python versions as follows:
 - Python versions will be installed under `/opt/python`.
 - A separate subdirectory will be created in that directory for each version of Python installed, e.g. `/opt/python/3.9.9`, `/opt/python/3.8.13`.
 - A symlink will be created in that directory that points to the currently active Python install, e.g. `/opt/python/current`.
 - Crontabs and rcfiles should prepend `/opt/python/current/bin` to the PATH environment variable.
 - Shebang lines in Python scripts should be changed to `#!/usr/bin/env python3` to use the correct version.

### Building/Installing Python
To build Python 3.9.9 on Ubuntu 18 (of course, replace 3.9.9 with whatever version of Python you're building):
 - Install the Python build-time dependencies: 
```sudo apt install build-essential libbz2-dev libffi-dev libfontconfig1-dev libfreetype6-dev libgdbm-compat-dev libgdbm-dev libice-dev liblzma-dev libncurses5-dev libpng-dev libpthread-stubs0-dev libreadline-dev libsm-dev libsqlite0-dev libsqlite3-dev libssl-dev libtinfo-dev libx11-dev libxau-dev libxcb1-dev libxdmcp-dev libxext-dev libxft-dev libxrender-dev libxss-dev libxt-dev lzma-dev tcl-dev tcl8.6-dev tk-dev tk8.6-dev uuid-dev x11proto-core-dev x11proto-dev x11proto-scrnsaver-dev x11proto-xext-dev xtrans-dev zlib1g-dev```
 - Download the Python source tarball: `curl -o /tmp/Python-3.9.9.tar.xz https://www.python.org/ftp/python/3.9.9/Python-3.9.9.tar.xz`
 - Unpack the source code: `pushd /tmp && tar xJf Python-3.9.9.tar.xz`
 - Configure and build it: `pushd Python-3.9.9 && ./configure --prefix=/opt/python/3.9.9 --enable-optimizations && make -j$(nproc)` 
 - Install it: `make install`
 - Update the symlink: `pushd /opt/python && rm -f current && ln -s 3.9.9 current`
 - Install pipenv and friends: `/opt/python/current/bin/pip3 install --upgrade pip && /opt/python/current/bin/pip3 install pipenv wheel`

Note that the Vagrant provisioning script at https://github.com/seattleflu/backoffice/tree/master/dev/vagrant/backoffice can build whatever version of Python you like as part of the `vagrant up` process.

### Upgrading SFS Software
Once the new version of Python is installed, existing virtualenvs must be rebuilt to use it.

#### `pipenv`-based projects
 - Do `pipenv --rm` in the project directory to completely remove the existing virtualenv.
 - If upgrading from one major version to another (e.g. 3.6 to 3.9), make sure the `python_version` setting in the `Pipfile` is set to allow the version you're upgrading to.
 - Ensure that the `id3c` and `id3c-customizations` hashes in `Pipfile` are up-to-date. To update them, find the hash of the appropriate commit in the id3c or id3c-customization repo's `git log`.
 - To set up the new virtualenv, do `PIPENV_VENV_IN_PROJECT=1 pipenv update`. This will regenerate the `Pipenv.lock` file with new versions of any dependencies (this is important if doing major version upgrades).
 - Test, test, test!

#### Virtualenv-based projects (Switchboard)
 - Ensure that the `id3c` hash in `requirements.in` is up-to-date. To update it, check the id3c repo's `git log` for the right commit to use.
 - Recreate the virtualenv using the new version of Python. This command will destroy and recreate the venv for you: `make venv` 
 - Update the `requirements.txt` file: `make requirements.txt`
 - Merge the changes back to Github.

#### uWSGI apps
uWSGI is built against a specific installation of Python and can easily get confused if multiple versions are present on a system. Specifically, if not using system Python, you shouldn't use the system uWSGI. Fortunately, it's easy to fix.
 - Install uWSGI to the global, non-system Python: `/opt/python/current/bin/pip3 install uwsgi`
 - Update the `/etc/systemd/system/uwsgi@.service` file to point to the new uWSGI binary, which is `/opt/python/current/bin/uwsgi`.
 - Restart any running uWSGI processes. 

## Production upgrade process
 - Before starting, make sure to merge any required changes for the new version of Python to the seattleflu repositories. In particular:
   - [id3c](https://github.com/seattleflu/id3c)
   - [id3c-customizations](https://github.com/seattleflu/id3c-customizations)
   - [backoffice](https://github.com/seattleflu/backoffice) (depends on the above)
   - [switchboard](https://github.com/seattleflu/switchboard) (_ibid_)
 - Pause all cronjobs, either by disabling them in the crontabs, or stopping cron entirely with `sudo systemctl stop cron`. Ensure that all cron jobs are stopped by monitoring `/var/log/syslog`.
 - Stop Apache: `sudo systemctl stop apache2`
 - Stop all uWSGI apps. You can get a list of them via `systemctl list-units uwsgi*`. Stop each with `systemctl stop <unit name>`.
 - Install the new version of Python, as described in [Building/Installing Python](Maintenance-and-Upgrading.md#buildinginstalling-python).
 - Install the new version of uWSGI, as described in [uWSGI apps](Maintenance-and-Upgrading.md#uwsgi-apps).
 - Ensure that the PATH environment variable in `/etc/environment` contains the correct path to the new version of Python first in the list. This is `/opt/python/current/bin`.
 - Log out and back in, or update your session's PATH variable to include that path.
 - Back up the existing `/opt/backoffice` and `/opt/sfs-switchboard` directories so the changes can easily be reverted if necessary.
 - Pull down the latest versions of the [backoffice](https://github.com/seattleflu/backoffice), [backoffice-apache2](https://github.com/seattleflu/backoffice-apache2), and [switchboard](https://github.com/seattleflu/switchboard) repos.
 - Recreate the pipenvs as described in [`Pipenv`-based projects](Maintenance-and-Upgrading.md#pipenv-based-projects), and virtualenvs as in [Virtualenv-based projects (Switchboard)](Maintenance-and-Upgrading.md#virtualenv-based-projects-switchboard).
 - Re-enable all the cron jobs.
 - Restart all the uWSGI apps with `sudo systemctl start <unit name>`.

### Reverting changes
 - Stop all cronjobs, probably with `sudo systemctl stop cron`.
 - Stop all uWSGI apps, and (if necessary) reset the path to the uWSGI binary in `/etc/systemd/system/uwsgi@.service`.
 - Delete the Python symlink: `rm /opt/python/current`. Point it at the correct install if still using an in-house-compiled version, or leave it deleted if using system Python.
 - Reset the following repos back to the appropriate commit:
   - [backoffice](https://github.com/seattleflu/backoffice) (in `/opt/backoffice`)
   - [backoffice-apache2](https://github.com/seattleflu/backoffice-apache2) (in `/etc/apache2`)
   - [switchboard](https://github.com/seattleflu/switchboard) (in `/opt/scan-switchboard`)
   - [id3c](https://github.com/seattleflu/id3c) and [id3c-customizations](https://github.com/seattleflu/id3c-customizations) may also need to be reset if the Python version has changed.

## Upgrading Postgres

### Useful Links
 - AWS Postgres upgrade guides: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.PostgreSQL.html#USER_UpgradeDBInstance.PostgreSQL.MajorVersion
 - Postgres/PostGIS version compatibility tables: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.PostGIS.html#CHAP_PostgreSQL.Extensions.PostGIS

### Cloning Production
 - Log on to AWS and navigate to the RDS console. Select the production instance and click the "Maintenance & Backups" tab.
 - Find the latest snapshot of production and restore it. This always creates a new database instance, so it's safe to do this for testing whenever you like.
   - It's best to use the same type and generation of instance as the snapshot's source (ie, `db.m5`). It's not necessary to use the same size (`4xlarge`), so use a smaller one and save money.
   - Make the name of the new instance extremely obvious, so you don't accidentally change production! I like to use "deleteme-seattleflu-upgradetest" or similar.
 - These databases are pretty expensive, so be sure to delete any test instances when you're done.
 
### The Postgres Upgrade Process
 - From the RDS Databases list, select the instance to be upgraded and click the "Modify" button.
 - Change the "DB Engine Version" to the new version of Postgres you'd like to upgrade the database to, _and nothing else_. Click the "Continue" button at the bottom.
 - Review the changes to be made, and select the "Apply immediately" button. There are several possibilities as to what will happen here:
   - Additional changes will need to be made in order to accomplish the upgrade. For instance, if the current instance type doesn't support the new version of the database, it will have to be changed first. If you attempt to proceed, you may get an error message like, "RDS does not support creating a DB instance with the following combination: DBInstanceClass=db.t2.small, Engine=postgres, EngineVersion=13.3, LicenseModel=postgresql-license. For supported combinations of instance class and database engine version, see the documentation."
   - Upgrading directly to the specified version isn't possible. This will occur when the version of PostGIS installed in the current database doesn't match the version available in the new one. In this case, upgrade to an intermediate version first. This error may not be displayed immediately, but rather will occur after `pg_upgrade` is invoked to attempt the upgrade, and a log file will be generated detailing the reason for the failure.
   - The upgrade can proceed as specified.
 - If working on production, schedule the upgrade to occur during a maintenance window during off-hours.
   - If working with a restored snapshot or on a development instance, it's safe to select the "Apply immediately" option.
 - The upgrade will take 10-60 minutes, during which time the database will be unavailable.

### Upgrading PostGIS
If Postgres and PostGIS both need to be upgraded, Postgres must be upgraded first. You'll need to upgrade to a version of Postgres that supports both the old and new versions of PostGIS, then upgrade PostGIS. If you want to upgrade Postgres further, you can then do so. 
 - **Upgrading PostGIS will close all current database connections.**
   - However, it's practically instantaneous, so it's generally safe to do during business hours. Running jobs will fail, but pick up where they left off during their next run.
 - Upgrade Postgres using the procedure above in [The Postgres Upgrade Process](Maintenance-and-Upgrading.md#the-postgres-upgrade-process).
 - Connect to the database as the `postgres` user.
 - Make sure you're in the database that has the extension installed: `SELECT extname,extversion FROM pg_extension WHERE lower(extname)='postgis';`
 - Show the current and available PostGIS extension versions: `SELECT * FROM pg_available_extensions WHERE lower(name) LIKE 'postgis%' ORDER BY name;`
 - Update the extension version: `ALTER EXTENSION postgis UPDATE;`
 - Complete the upgrade: `SELECT postgis_extensions_upgrade();`
 - Make sure all the bits are correct: `SELECT postgis_full_version();`

## Upgrading the Operating System
