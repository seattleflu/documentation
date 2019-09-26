# Deploying ID3C Changes

## Prerequisites
Before you get started, you'll need the following:

* a personal admin account to the production ID3C database plus the login information for the `postgres` user account.
* a configured `sqitch` environment on your local machine.
  > See [Infrastructure] → **Databases (PostgreSQL)** → [sqitch configuration]
* a public key shared with the `ubuntu` account on `backoffice.seattleflu.org`.

## Steps for deployment:
1. Merge code changes in [ID3C] or [ID3C-customizations] to each master branch, respectively.

### Schema changes to the database
> If you have no schema changes to deploy, you may skip this section.
2. Deploy database schema changes via `sqitch` from your local machine.
   Run the following commands, replacing the curly-bracketed text with your specifications.

   First, check that the plan looks good.

        PGUSER={your-admin-username} sqitch status {database name}

   > Tip: check `~/.pg_service.conf` for your admin username and other connection details

   If everything looks good, run the following **using the `postgres` user**.

        PGUSER=postgres sqitch deploy {database name}

3. Grant roles to the `backoffice` database automation user via

        PGUSER={your-admin-username} PGSERVICE={service name} psql

   Once inside of the `psql` prompt, run:

        grant "{role}" to "backoffice-etl";


### Code changes to [ID3C]
> If you have no code changes to deploy, you may skip this section.

4. Log onto the `backoffice` server.
5. Go to `/opt/id3c-production` and run `git pull`.
6. Add relevant `cron` jobs for any new etl routines to `/etc/cron.d/backoffice`.
   Add any necessary environment variables necessary to the top of this file.
   > Note: you'll need `sudo` permissions to edit `/etc/cron.d/backoffice`.
7. Add relevant api variables as necessary and restart api server by running `sudo systemctl restart uwsgi`
   > See the uWSGI documentation under [Infrastructure] → **Hosts** → [backoffice.seattleflu.org]
8. If you installed new Python dependencies via [Pipenv], be sure to run `pipenv sync` to install the new dependencies


### Data uploads to the database
> If you have no data to upload, you may skip this section.

9. Upload data to the `receiving` area of the database from your local machine.
   Run the desired `id3c` command(s) with a prefix of `PGSERVICE={service name}`.


[Infrastructure]: ./infrastructure.md
[ID3C]: https://github.com/seattleflu/id3c
[ID3C-customizations]: https://github.com/seattleflu/id3c-customizations
[backoffice.seattleflu.org]: infrastructure.md#backofficeseattlefluorg
[sqitch configuration]: infrastructure.md#sqitch-configuration
[Pipenv]:https://pipenv.readthedocs.io/en/latest/
