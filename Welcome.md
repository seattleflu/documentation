Welcome to Seattle Flu Study (SFS) GitHub documentation! If you're reading this,
you're probably new here. This page, while currently a stub, dreams of being a
one-stop shop for getting you set up and answering your questions before you
start using or contributing to our code.

- [Team philosophies](#team-philosophies)
  - [Open science](#open-science)
    - [Safe to share publicly](#safe-to-share-publicly)
    - [Don't share publicly](#dont-share-publicly)
  - [Inclusion and diversity](#inclusion-and-diversity)
- [Slack](#slack)
- [Permissions & Access](#permissions--access)
- [Responsibilities](#responsibilities)
  - [ID3C](#id3c)
    - [Data ingestion](#data-ingestion)
    - [Data Quality](#data-quality)
    - [Barode minting](#barode-minting)
  - [Return of results](#return-of-results)
    - [Lab Result Reports](#lab-result-reports)
    - [Securelink](#securelink)
  - [Labelmaker](#labelmaker)
  - [Metabase](#metabase)
  - [SCAN Switchboard](#scan-switchboard)
- [Tools](#tools)
  - [Git](#git)
    - [GitHub Actions](#github-actions)
  - [Python](#python)
    - [Pipenv](#pipenv)
    - [Flask](#flask)
    - [Click](#click)
  - [PostgreSQL](#postgresql)
    - [Sqitch](#sqitch)
  - [AWS](#aws)
  - [Tests](#tests)
    - [Doctests](#doctests)
    - [Type Checks](#type-checks)
- [Misc](#misc)
  - [REDCap](#redcap)
  - [FHIR](#fhir)
- [Development](#development)
  - [Development tools](#development-tools)
  - [Running ID3C](#running-id3c)
    - [Test your installation](#test-your-installation)
    - [Connecting to production vs. local databases](#connecting-to-production-vs-local-databases)
    - [Re-run an ETL process (without bumping revision number)](#re-run-an-etl-process-without-bumping-revision-number)
  - [Environment configuration](#environment-configuration)
    - [Editor configuration](#editor-configuration)
    - [Git configuration](#git-configuration)
    - [Prevent wrapping within psql (optional)](#prevent-wrapping-within-psql-optional)


## Team philosophies

### Open science
The Seattle Flu Study practices open science.
This means that our code and documentation (with very few, notable exceptions) is all open source.
Even though our work can be highly specific and not always applicable to the public domain, we use a "public by default" rather than a "private by default" approach to our developer material.
We only privatize repositories or documentation that contain sensitive data or whose release could pose a security risk to the study or its members.
Here is a quick guide to what's safe to share and what's not.

#### Safe to share publicly
* Documentation that is Seattle Flu specific but not sensitive
* Links to Slack conversations
* Links to Trello cards
* Links to Metabase (or other apps at backoffice.seattleflu.org)
* First names of study team contacts


#### Don't share publicly
* Personally identifiable information of study participants or employees, including full names or email addresses
* Real study barcodes
* Secrets
  * Passwords
  * API authorization IDs
  * API access tokens
  * deidentification secrets
  * etc.
* Links to Google Drive (the risk is that link-based sharing could be turned on by accident for documents/folders, allowing access to anyone with the link)


### Inclusion and diversity
We aim to write our documentation and code comments with inclusion and diversity in mind.
We've found the [Google inclusive documentation style guide](https://developers.google.com/style/inclusive-documentation) to be a useful starting point for these considerations.


## Slack
Slack is the primary method of communication used by Seattle Flu Study members.
Our culture is to post messages in public channels wherever possible so that as
much context as possible can be gained by relevant parties. We recognize that
private channels are often appropriate for certain types of data-sensitive or
intra-team communication, but we discourage the use of direct messages for
study-related questions, requests, or planning.

An overview of the SFS slack:
- **#channel-map** - organized list of broad channels and their purposes
- **#directory** - study-wide directory

Noteworthy Slack channels for SFS developers include:
- **#barcodes** - used for requesting newly minted barcodes. See the channel description for the upload destination for new labels.
- **#clia** - used for questions about CLIA compliance
- **#data-transfer-labmed (private)** - a shared channel used to communicate with UW SecureLink about data sharing
- **#data-transfer-nwgc** - used to communicate with Northwest Genomics Center about data sharing
- **#data-transfer-retrospectives** - used to communicate with Seattle Childrens about data sharing
- **#id3c** - used to discuss the [ID3C] code base
- **#id3c-alerts** - alert system for [cronjobs] that run on the backoffice server
- **#informatics** - questions about [SFS ID3C views] or [Seattle Flu Metabase] queries
- **#ncov-reporting (private)** - alert system for positive or inconclusive hCoV-19 results
- **#record-troubleshooting** - used to communicate bad barcodes or REDCap records
- **#redcap** - general REDCap questions
- **#software** - software team chat, for internal team communications
- **#website** - questions about the public-facing study website (currently managed by Formative)

## Permissions & Access
Before you can get access to sensitive data, you must complete all required
trainings and sign the confidentiality agreement. Please get in touch with the
management team to complete all the necessary paperwork!

You will need access to the following:
- [ID3C] - basic user, admin user, & postgres user
- [Seattle Flu Metabase] - Admin, Seattle Flu Study, & hCoV-19 visibility groups
- [Seattle Flu GitHub]
    - private [specimen-manifests] repo
    - private [security-audit] repo (additional documentation)
    - LabMed private [securelink] repo
- [Seattle Flu "backoffice" server](https://github.com/seattleflu/security-audit#overview), the core of our infrastructure
- AWS access
    - [Seattle Flu Study AWS account]
    - [Brotman Baty Institute AWS account]
    - [Fred Hutch Bedford S3 Bucket](https://sciwiki.fredhutch.org/scicomputing/store_objectstore/#economy-cloud-s3)
    - Securelink S3 Bucket
- UW OneDrive - for specimen manifest sheets
- [UW ITHS REDCap] plus access to all SFS/SCAN projects
- [SCAN Switchboard]
- Kaiser Permanente Secure File Transfer
- [#record-troubleshooting Trello Board](https://trello.com/b/PAlgvsEO/record-troubleshooting)

## LastPass
LastPass is a UW-approved password management tool and is utilized by SFS developers to manage individual private and team shared passwords, keys, and secret keys. More information on LastPass can be found [here.](https://itconnect.uw.edu/wares/mws/my-workstation/security/lastpass/)

Enrolling in UW's LastPass Enterprise account requires specific steps. (Please note, order of operations here is critical! If you do not complete these steps in order, your account may not be configured correctly):
1. Request an account through UW using your NetID. Visit this [page](https://groups.uw.edu/group/u_passman_users_requested) and click "Join this group".
2. Wait (up to 60 minutes) to receive an email from LastPass to activate your account. Follow the link in that email to reset your master password.
3. After resetting your master password, download and install the appropriate LastPass browser extension or log in directly through the [LastPass](https://www.lastpass.com/) website.

After successfully logging in:
- Confirm your account is correctly confguired with your UW email address and "Enterprise User" in the top-right corner.
- Confirm that you have access to the "Shared-SFS" shared folder under "All Items" from the navigation menu on the left.

## Responsibilities
SFS developers maintain the following codebases and apps.

### ID3C
Core [ID3C] and its extensions, [ID3C-customizations], are the repositories that contain our CLI tools, ETL pipelines, database schemas, database roles, and API endpoints.

The long term vision for [ID3C's design] is to create a general platform that can be used by other researchers, in other cities, for other organisms.
De-coupling SFS/SCAN-specific code from [ID3C] and porting it to [ID3C-customizations] is still a work in progress.

#### Data ingestion
Data sources include prospective (SFS or SCAN enrollments via REDCap) and
retrospective (Seattle Childrens, UW Medicine, Kaiser Permanente, or Fred Hutch
data exports)

See more details about data ingestion at [data-flow](data-flow).

#### Data Quality
There are data quality checks throughout the ingestion and ETL pipelines in [ID3C]/[ID3C-customizations].
Errors and warnings are posted in the __#id3c-alerts__ Slack channel.

See more details about how to handle common errors at [troubleshooting](troubleshooting).

#### Barode minting
The dev team gets requests for minting new barcodes in the __#barcodes__ Slack channel.
More detailed instructions are available at [barcodes](barcodes).

### Return of results
CLIA certified lab results are returned to participants via a web portal.
The dev team is responsible for generating PDF reports for these lab results,
exporting the results and PDFs to UW LabMed, and maintaining the SCAN customizations for the web portal.

#### Lab Result Reports
The [lab-result-reports] repo contains the templates and code for generating the individual PDF reports for lab results.

#### Securelink
SCAN is currently using the UW LabMed [results portal](https://securelink.labmed.uw.edu/scan)
since their infrastructure is considered CLIA approved.
The [securelink] repo contains the code for the results portal.
The SFS dev team is only responsible for maintaining the front-end customizations for the SCAN study.

### Labelmaker
Used with barcode minting.

### Metabase
[Metabase] is an open-source, B.I. tool that is used widely across the SFS.
The [Seattle Flu Metabase] service is [documented here](https://github.com/seattleflu/backoffice/blob/master/metabase/README.md).

### SCAN Switchboard
The [SCAN Switchboard] is an internal tool built to speed up the lab's unboxing and quality control processes for recieved SCAN kits.
The [source code](https://github.com/seattleflu/scan-switchboard) is separate from the [deployment configuration](https://github.com/seattleflu/backoffice/blob/master/scan-switchboard/README.md).

## Tools
### Git
Git is our version control tool, and our repositories are all hosted on [GitHub].
We generally follow [these guidelines](https://chris.beams.io/posts/git-commit/) for writing git commit messages.
We typically do development in feature branches and merge into master.
Generally, we deploy from master (or images/snapshots created from master).
Before merging, we rebase our commits to create the most human-readable history of our codebase as possible.
We avoid moving and changing code in the same commit.


#### GitHub Actions
We use GitHub Actions in the following repositories:
* [seattleflu/lab-result-reports](https://github.com/seattleflu/lab-result-reports/actions)
* [seattleflu/documentation](https://github.com/seattleflu/documentation/actions)

### Python
Python 3 is the programming language of choice for our ETL pipelines.
We also use it for other tasks or services in the [backoffice] repo.

#### Pipenv
Across our codebases, we manage Python dependencies with [Pipenv].
See an [example Pipfile here](https://github.com/seattleflu/id3c/blob/master/Pipfile).

#### Flask
We use [Flask] to set up the [ID3C] web API.

#### Click
We use [Click] to set up the [ID3C] command-line interface.

### PostgreSQL
We're currently using PostgreSQL version 10 for our production database with plans to upgrade to PostgreSQL 13.

See [ID3C's design] for a motivation on the schema setup of our database.
See [this flowchart](id3c-warehouse-schema.pdf) for an overview of the `warehouse` schema of the `seattleflu` database.

#### Sqitch
See our [motivation for using sqitch].

### AWS
See our high level [AWS documentation].

### Tests
We currently don't have many tests in ID3C, as we tend to rely more heavily on
our alert system (see the **#id3c-alerts** Slack channel).

#### Doctests
Run doctests in the ID3C or ID3C-customizations repo with `pytest -v`.

#### Type Checks
Run mypy type checking in the ID3C or ID3C-customizations repo with `./dev/mypy`.

## Misc
### REDCap
[REDCap] is an online tool used to build and manage surveys for collecting information from SFS/SCAN study participants.
There is a REDCap team within SFS that works with UW ITHS to build and manage these surveys.
Therefore, the dev team is not immediately responsible for these surveys,
but it is useful to understand how REDCap works to debug ingestion and data quality issues that may arise.

See [ITHS REDCap Training] to sign up for classes and/or read training materials.

The [REDCap CLI](https://github.com/tsibley/redcap-cli) can be helpful for digging into a project's data.

### FHIR
To be able to better [integrate with other data systems], we have begun adopting [HL7 FHIR] vocabulary and documents wherever possible.
Our REDCap DET ETLs produce FHIR bundles that then get processed by our [FHIR ETL].
See some [minimal FHIR bundle examples].


## Development
### Getting set up
* [Macbook-setup](https://github.com/seattleflu/documentation/blob/master/Macbook-setup.md)
### Development tools
* [Refresh your local dev database] with a copy from production

### Running ID3C
#### Test your installation
From within the `id3c` or `id3c-customizations` repo, run the following:
```sh
PGDATABASE=seattleflu pipenv run id3c --help
```

#### Connecting to production vs. local databases
Here's how you might see the identifier (barcode) sets in our production instance:
```sh
PGSERVICE=seattleflu-production pipenv run id3c identifier set ls
```
whereas in local testing, I'd do:
```sh
PGDATABASE=seattleflu pipenv run id3c identifier set ls
```
PGSERVICE points to a named service definition in a `~/.pg_service.conf` file.

ID3C doesn't provide application-specific connection defaults, and it relies on the [standard Pg environment variables](https://www.postgresql.org/docs/current/libpq-envars.html) to define the connection.

#### Re-run an ETL process (without bumping revision number)
Set the processing log for all targeted rows to be blank.
When any ETL, like the REDCap DET ETL, is run, it will process all rows with a blank processing log for the current revision (e.g. 12).
Running the following code will make the affected rows (recieved on or after Jun 06, 2020) be picked up in a subsequent REDCap DET ETL run:
```sql
update
   receiving.redcap_det
set
   processing_log = '[]'
where
   received > '2020-06-25';
```

To process `redcap-det`, run
```sh
PGDATABASE=seattleflu pipenv run id3c etl redcap-det --prompt
```

To process `clinical` run
```sh
PGDATABASE=seattleflu pipenv run id3c etl clinical --prompt
```

If you don't have `LOG_LEVEL=debug` turned on, full logs should be available on your system via
```sh
grep seattleflu /var/log/syslog
```

### Environment configuration
#### Editor configuration
We configure our editors to use spaces instead of tabs, trim trailing whitespace at the end of each line, and add an empty newline to the end of each file.

If you use VS Code, add these settings:
"files.insertFinalNewline": true,
"files.trimFinalNewlines": true,
"files.trimTrailingWhitespace": true,

#### Git configuration
We add the following configuration to our global `.gitconfig`:
```
[pull]
    rebase = true
```
When pulling from master, local changes are now rebased on top of the master branch instead of creating "Merge branch 'master'..." commits.

#### Prevent wrapping within psql (optional)
Set pager environment variable to `less` and specify which `less` method to use.
If there's less than a screen full of information, don't page it.
```sh
PAGER=less LESS=SFRXi psql seattleflu
```
To save these settings, add the following lines to your `~/.psqlrc`.
```sql
\setenv PAGER less
\setenv LESS SRFXi
```




[AWS documentation]: https://github.com/seattleflu/security-audit#aws
[backoffice]: https://github.com/seattleflu/backoffice
[Click]: https://click.palletsprojects.com
[cronjobs]: https://github.com/seattleflu/backoffice/tree/master/crontabs
[FHIR ETL]: https://github.com/seattleflu/id3c/blob/master/lib/id3c/cli/command/etl/fhir.py
[Flask]: https://flask.palletsprojects.com
[GitHub]: https://github.com
[HL7 FHIR]: https://www.hl7.org/fhir/
[ID3C]: https://github.com/seattleflu/id3c
[ID3C's design]: https://github.com/seattleflu/id3c#design
[ID3C-customizations]: https://github.com/seattleflu/id3c-customizations
[integrate with other data systems]: https://github.com/seattleflu/id3c#integration-with-other-data-systems
[ITHS REDCap Training]: https://www.iths.org/investigators/services/bmi/redcap/curriculum/
[lab-result-reports]: https://github.com/seattleflu/lab-result-reports
[Metabase]: https://www.metabase.com/
[minimal FHIR bundle examples]: https://github.com/seattleflu/documentation/tree/master/fhir
[motivation for using sqitch]: https://github.com/seattleflu/id3c#deploying
[Pipenv]: https://pipenv.pypa.io/en/latest/
[REDCap]: https://www.project-redcap.org/
[Refresh your local dev database]: https://github.com/seattleflu/backoffice/tree/master/dev
[SCAN Switchboard]: https://backoffice.seattleflu.org/switchboard/
[Seattle Flu Github]: https://github.com/seattleflu
[Seattle Flu Metabase]: https://backoffice.seattleflu.org/metabase/
[Seattle Flu Study "backoffice" server]: https://github.com/seattleflu/security-audit#overview
[Seattle Flu Study AWS account]: https://github.com/seattleflu/security-audit#aws
[securelink]: https://github.com/nkrumm/securelink
[security-audit]: https://github.com/seattleflu/security-audit
[SFS ID3C views]: https://github.com/seattleflu/id3c-customizations/blob/master/schema/deploy/shipping/views.sql
[specimen-manifests]: https://github.com/seattleflu/specimen-manifests
[UW ITHS REDCap]: https://redcap.iths.org/
