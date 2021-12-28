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
 - Install the Python build-time dependencies: `sudo apt install build-essential libbz2-dev libffi-dev libfontconfig1-dev libfreetype6-dev libgdbm-compat-dev libgdbm-dev libice-dev liblzma-dev libncurses5-dev libpng-dev libpthread-stubs0-dev libreadline-dev libsm-dev libsqlite0-dev libsqlite3-dev libssl-dev libtinfo-dev libx11-dev libxau-dev libxcb1-dev libxdmcp-dev libxext-dev libxft-dev libxrender-dev libxss-dev libxt-dev lzma-dev tcl-dev tcl8.6-dev tk-dev tk8.6-dev uuid-dev x11proto-core-dev x11proto-dev x11proto-scrnsaver-dev x11proto-xext-dev xtrans-dev zlib1g-dev`
 - Download the Python source tarball: `curl -o /tmp/Python-3.9.9.tar.xz https://www.python.org/ftp/python/3.9.9/Python-3.9.9.tar.xz`
 - Unpack the source code: `pushd /tmp && tar xJf Python-3.9.9.tar.xz`
 - Configure and build it: `pushd Python-3.9.9 && ./configure --prefix=/opt/python/3.9.9 --enable-optimizations && make -j$(nproc)` 
 - Install it: `make install`
 - Update the symlink: `pushd /opt/python && rm -f current && ln -s 3.9.9 current`
 - Install pipenv and friends: `/opt/python/current/bin/pip3 install --upgrade pip setuptools wheel && /opt/python/current/bin/pip3 install pipenv`

### Upgrading SFS Software
Once the new version of Python is installed, existing virtualenvs must be rebuilt to use it.

#### `pipenv`-based projects
 - Do `pipenv --rm` in the project directory to completely remove the existing virtualenv.
 - If upgrading from one major version to another (e.g. 3.6 to 3.9), make sure the `python_version` setting in the `Pipfile` is set to allow the version you're upgrading to.
 - To set up the new virtualenv, do `PIPENV_VENV_IN_PROJECT=1 pipenv update`. This will regenerate the `Pipenv.lock` file with new versions of any dependencies (this is important if doing major version upgrades).
 - Test, test, test!

FIXME: this needs to be expanded (especially for switchboard)
#### Virtualenv-based projects
 - Destroy the existing virtualenv.
 - Create a new virtualenv using the new version of Python.

## Upgrading Postgres

## Upgrading the Operating System
