# Deploying id3c or id3c-customizations #

## Prerequisites
Before you get started, you'll need the following:

* a personal admin account to the production ID3C database plus the login information for the `postgres` user account.
* a configured `sqitch` environment on your local machine.
  > See [Infrastructure] → **Databases (PostgreSQL)** → [sqitch configuration]
* a public key shared with the `ubuntu` account on `backoffice.seattleflu.org`.

## Steps for deployment:
1. Merge code changes in [ID3C] or [ID3C-customizations] to each master branch, respectively.
2. Run `pipenv update` in the `id3c-production` directory of your [backoffice]
   checkout.  This will lock ID3C and our customizations at the latest state of
   their master branch on GitHub.  Review, commit, and push the changes.

### Schema changes to the database
> If you have no schema changes to deploy, you may skip this section.
3. Deploy database schema changes via `sqitch` from your local machine.
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


### Code changes to [ID3C]
> If you have no code changes to deploy, you may skip this section.

4. Log onto the `backoffice` server.
5. Navigate to the `/opt/backoffice` directory and run `git pull`.
6. Add any newly needed secret environment variables under `id3c-production/env.d/…`.
   (Non-secret environment variables should be committed and pulled in via git.)
7. Install the latest production environment with `(cd id3c-production; pipenv sync)`.
8. Install the latest crontabs with `sudo make -C crontabs`.
9. Reload the web API backend by running `sudo systemctl reload uwsgi`.
   > See the uWSGI documentation under [Infrastructure] → **Hosts** → [backoffice.seattleflu.org]


### Data uploads to the database
> If you have no data to upload, you may skip this section.

10. Upload data to the `receiving` area of the database from your local machine.
    Run the desired `id3c` command(s) with a prefix of `PGSERVICE={service name}`.


[Infrastructure]: infrastructure
[backoffice]: https://github.com/seattleflu/backoffice
[ID3C]: https://github.com/seattleflu/id3c
[ID3C-customizations]: https://github.com/seattleflu/id3c-customizations
[backoffice.seattleflu.org]: infrastructure#backofficeseattlefluorg
[sqitch configuration]: infrastructure#sqitch-configuration
[Pipenv]:https://pipenv.readthedocs.io/en/latest/

# Deploying scan-switchboard #

1. Log onto the `backoffice` server.
2. Navigate to the `/opt/scan-switchboard` directory and run `git pull`.
3. Add any newly needed secret environment variables under `id3c-production/env.d/…`.
   (Non-secret environment variables should be committed and pulled in via git.)
4. Install the latest code with `pipenv sync`.
5. Restart scan-switchboard with `sudo systemctl restart scan-switchboard`

There is a crontab that syncs the switchboard. If you have changed something in scan-switchboard that needs accompanying changes to the crontab, make that change in the backoffice repository and deploy that too.
