- [Overview](#overview)
- [Deep dive](#deep-dive)
- [Setup](#setup)
  - [Connect to the production ID3C database](#connect-to-the-production-id3c-database)
  - [Install dependencies](#install-dependencies)
  - [Clone the backoffice repo](#clone-the-backoffice-repo)
  - [Install your python environment](#install-your-python-environment)
  - [Configure REDCap API Tokens environment variables](#configure-redcap-api-tokens-environment-variables)
- [Troubleshooting](#troubleshooting)

> Note: this workflow only works for Unix systems (MacOS and Linux).
Windows is not supported.

## Overview

The scripts in [the `wa-doh-linelists` directory] of the [backoffice] repo will create linelists of ID3C and REDCap data for submission to the Washington Department of Health.
See the [specification for the linelist data format].

The [generate script] is the high-level script that exports ID3C data, merges it with REDCap report data, and performs transformations all in one.
It requires test result `DATE` as an argument in `YYYY-MM-DD` format.
It also requires the [REDCap API tokens environment variables](#redcap-tokens-environment-variables) and a [connection to an ID3C database](#connecting-to-the-production-id3c-database) (see below).

There are multiple ways to configure your environment, but here, we'll walk through one, specific way that the dev team uses.
Once you've configured your environment properly, you can generate linelists with one command.
Don't forget to [install the latest python environment](#install-your-python-environment) before each run, otherwise you may run into unexpeted bugs!

Copy and paste this following example using `2021-01-01` as the target results date:

> Note: **Don't forget to [install the latest development environment](#install-your-python-environment) before each run!**

    cd ~/backoffice

    PGSERVICE=seattleflu-production \
        envdir ./id3c-production/env.d/redcap \
        ./bin/wa-doh-linelists/generate 2021-01-01


The output linelists are stored locally in the `backoffice` repo under `~/backoffice/bin/wa-doh-linelists/data/linelist_{DATE}.csv`.
You can navigate to these files in your window explorer (e.g. Finder) by opening the `backoffice` folder in your home directory.


## Deep dive

The `generate` script invoked above is comprised of two, separate scripts.
Calling these individual scripts is useful if you want lower level control over the input and output of the generated linelists.

1. One of them exports linelist data from ID3C given a date (and requires a connection to an ID3C database):

        cd ~/backoffice

        PGSERVICE=seattleflu-production \
            ./bin/wa-doh-linelists/export-id3c-hcov19-results 2021-01-01 > ./bin/wa-doh-linelists/data/id3c-export-2021-01-01.csv

2. The other merges ID3C linelist data and REDCap report data, transforming and standardizing them into a format WA DoH expects.
   This script reqiures a test result `--date` in YYYY-MM-DD format and `--id3c-data` which, if you choose to run this script instead of `generate`, you'll need to export using the `export-id3c-hcov19-results` script  explained above.

        cd ~/backoffice

        PIPENV_PIPFILE=./id3c-production/Pipfile \
        pipenv run ./generate \
            --date 2021-01-01 \
            --id3c-data ./bin/wa-doh-linelists/data/id3c-export-2021-01-01.csv

    This script also takes two, optional arguments:

    * `--project-id` filters the linelist export to only product linelists for the single, given project ID.
    * `--output-dir` declares the output directory of where you want the `linelist_{DATE}.csv` files stored.

    See more information about the `transform` script with `./bin/wa-doh-linelists/transform --help`.


## Setup

### Connect to the production ID3C database

> You only have to complete these steps once.

First, you'll need a username and password for the ID3C production database to complete this step.
If you don't have or know your username or password, please contact the `@dev-team` on Slack at the **#id3c** channel.

We have to point our [generate script] to a database.
Here, we'll walk through how to configure a PostgreSQL service definition.

First, open up a new terminal, and type the following:

    nano ~/.pgpass

Paste the following into this file, substituting `my-user-name` and `my-password` with your ID3C database credentials.
Keep the colon (`:`) separating them.

    production.db.seattleflu.org:5432:*:my-user-name:my-password

Then, press `CTRL+X` to exit.
Remember to save your work!
(Press `Y` then hit `Enter` to confirm the original save location.)
<mark>**IMPORTANT:**</mark> Once you've exited the file, restrict its permissions with:

    chmod 600 ~/.pgpass


Next, type the following:

    nano ~/.pg_service.conf


Inside of this file, paste the following configuration, substituting `my-user-name` with your ID3C database username.

    [seattleflu-production]
    host=production.db.seattleflu.org
    user=my-user-name
    dbname=production
    port=5432

Exit nano and save your work.

Now, you're ready to point a command to the ID3C production database by calling it with your newly configured database service definition.

    PGSERVICE=seattleflu-production example-command


### Install dependencies

> You only have to complete these steps once.

1. **`envdir`**

    Check if `envdir` is installed with:

        which envdir

    If you see no output, install it with the following:

        pip install envdir


2. **`pipenv`**

    Check if `pipenv` is installed with:

        which pipenv

    If you see no output, install it with:

        pip install pipenv


3. **python 3.6**

   You'll need to have python 3.6 installed.
   if you don't have it installed, one way to do it is with [pyenv].
   I would recommend trying to complete the [step on installing your python environment](#install-your-python-environment) and coming back to this step only if you get errors about not having python 3.6 installed.
   If you need to install python 3.6, and you're on MacOS, run:

        brew install pyenv

    Then run:

        pyenv install 3.6.9

    If you are getting errors here, you may need to also run:

        xcode-select --install


### Clone the backoffice repo

> You only have to complete this step once.

If you haven't done so already, clone the `backoffice` git repository to your local machine.
In this example, we'll put it in our home directory.

    cd ~/

    git clone https://github.com/seattleflu/backoffice.git


### Install your python environment

> You should run this step every time.

Once you've installed `pipenv` and python 3.6, install the python development environment by running the following commands:

    cd ~/backoffice

    git pull --rebase

If you see the message "`Already up to date.`," you're done with this step!
Otherwise, run the following, too:

    PIPENV_PIPFILE=./id3c-production/Pipfile pipenv sync

This may take a few minutes.


### Configure REDCap API Tokens environment variables

> You need to do these steps once per REDCap project.

REDCap requires a separate environment variable for every project whose data we wish to export programmatically.

    cd ~/backoffice/id3c-production/env.d/

    ls

There, you'll see several folders.
We'll be targeting two of them for creating linelists.
You'll need to copy your REDCap API token from each project and create a new file containing only the token.
We create file names using this pattern: `REDCAP_API_TOKEN_redcap.iths.org_{PROJECT_ID}`.
Here's an example of creating a new environment variable for the SCAN IRB English project (project ID 22461) with the text editor `nano`:

    nano redcap/REDCAP_API_TOKEN_redcap.iths.org_22461

Note that you are literally typing the string `REDCAP_API_TOKEN` here.
Once you're inside the file with `nano`, paste your actual token copied from REDCap.
Then, press `CTRL+X` to exit.
Remember to save your work!
(Press `Y` then hit `Enter` to confirm the original save location.)

Repeat this process for every SCAN REDCap project you're targeting in the [linelist configuration file] (also at `~/backoffice/etc/wa-doh-linelists.yaml`).

Then, when you're done with SCAN projects, repeat the process above for all the SFS projects.

Now, when you're calling a command that requires REDCap API tokens as environment variables, you can do so by preceding the `envdir` call before the script (but AFTER any other variable declarations like `PGSERVICE`). e.g.

    envdir ./id3c-production/env.d/redcap \
        example-command


## Troubleshooting

The linelist generation code will fail if duplicate collection barcodes exist in any one REDCap project.
If duplicates exist, you'll see an error message like this:
```
Exception: Duplicate barcodes detected in project 11111: 'Seattle Flu Study - Example Project'

  record_id collection_barcode
0      123           aaaaaaaa
1      234           aaaaaaaa
```

If the duplicate collection barcode problem can't be easily fixed, it's possible to modify our linelist configuration file so that we can continue to generate linelists while dropping the problematic REDCap project.

To drop a REDCap project from the linelist generation, open up `./etc/wa-doh-linelists.yml` in a text editor (such as `nano`, described in the [setup](#setup) steps).
Sections of the configuration file are separated with three hyphens (`---`).
Find the section pertaining to the problematic REDCap project.
For example, let's pretend the linelist generation gave an error message complaining about:
> project 19212: Seattle Flu Study - Asymptomatic Enrollments

Find the section in the file `./etc/wa-doh-linelists.yml` that starts with:

    ---
    name: Seattle Flu Study - Asymptomatic Enrollments
    project_id: 19212

Delete everything starting with the section separator, `---`, until the next separator (or the end of the file if no other section exists).
Save your edits.
Now, when you run the linelist generation code, the SFS Asymptomatic enrollments project will be excluded.

Once the duplicate collection barcode problem is fixed, you can refresh the `./etc/wa-doh-linelists.yml` config file back to its original contents by running:

    git restore ./etc/wa-doh-linelists.yml


[the `wa-doh-linelists` directory]: https://github.com/seattleflu/backoffice/tree/master/bin/wa-doh-linelists
[backoffice]: https://github.com/seattleflu/backoffice/
[specification for the linelist data format]: https://github.com/seattleflu/backoffice/blob/master/bin/wa-doh-linelists/docs/SFS_DOH_Linelist_Data_Formats.xlsx
[generate script]: https://github.com/seattleflu/backoffice/blob/master/bin/wa-doh-linelists/generate
[pyenv]: https://github.com/pyenv/pyenv
[linelist configuration file]: https://github.com/seattleflu/backoffice/blob/master/etc/wa-doh-linelists.yaml
