Run by the Bedford Lab, currently managed mostly by Thomas.

Unless noted otherwise, all of this is running under the AWS account
296651737672.

## Navigation
* [Hosts](#hosts)
* [Databases (PostgreSQL)](#databases-postgresql)
* [Networking and security groups](#networking-and-security-groups)
* [DNS](#dns)
* [Email](#email)


## Hosts

### backoffice.seattleflu.org

_Internal tooling_

* Testing [ID3C API](https://github.com/seattleflu/id3c) at `/testing/api`
* Production [ID3C API](https://github.com/seattleflu/id3c) at `/production/api`
* [Metabase](https://metabase.com) at `/metabase`
* [Lab Labels](https://github.com/tsibley/Lab-Labels) at `/labels`
* [Scan Switchboard](https://github.com/seattleflu/scan-switchboard) at `/switchboard`
* [Husky Musher](https://github.com/seattleflu/husky-musher) at `/husky-musher`

Hosted on an EC2 instance.

Configuration of interest includes

* [Webpage source and service configs](https://github.com/seattleflu/backoffice) (`/opt/backoffice`)

* [ID3C](https://github.com/seattleflu/id3c) and [ID3C-customizations](https://github.com/seattleflu/id3c-customizations) environments (`/opt/backoffice/id3c-testing`, `/opt/backoffice/id3c-production`)

* [Metabase container config and data](https://github.com/seattleflu/backoffice/tree/master/metabase) (`/opt/backoffice/metabase`)

* [Lab Labels container config](https://github.com/seattleflu/backoffice/tree/master/lab-labels) (`/opt/backoffice/lab-labels`)

* [SCAN Switchboard config](https://github.com/seattleflu/backoffice/tree/master/scan-switchboard) (`/opt/backoffice/scan-switchboard`)

* [Husky Musher config](https://github.com/seattleflu/backoffice/tree/master/husky-musher) (`/opt/backoffice/husky-musher`)


* uWSGI (`/etc/uwsgi`)
    - Apps enabled: `api-testing`, `api-production`, `husky-musher`
    - App environment using envdirs in `/etc/uwsgi/env.d`

* Apache2 (`/etc/apache2`) (see private [backoffice-apache2 repo](https://github.com/seattleflu/backoffice-apache2) for source control)
    - Modules enabled: `ssl`, `proxy`, `proxy_uwsgi`
    - Sites enabled: `backoffice`, `backoffice-le-ssl`
    - Reverse proxies to API via uWSGI socket
    - Reverse proxies to Husky Musher via uWSGI socket
    - Reverse proxies to Metabase via HTTP
    - Reverse proxies to Lab Labels via HTTP
    - Reverse proxies to SCAN Switchboard via HTTP

* Let's Encrypt (`/etc/letsencrypt`)
    - Managed by `certbot`
    - Used by `backoffice-le-ssl` Apache site config
    - Auto-renewing

* Docker
    - `metabase` container defined using `/opt/backoffice/metabase/create-container`
    - `lab-labels` container defined using `/opt/backoffice/lab-labels/create-container`
    - run via systemd

* systemd
  * Apps enabled:
    * Metabase: `/etc/systemd/system/metabase.service` → `/opt/backoffice/metabase/metabase.service`
    * Lab Labels: `/etc/systemd/system/lab-labels.service` → `/opt/backoffice/lab-labels/lab-labels.service`
    * SCAN Switchboard: `/etc/systemd/system/scan-switchboard.service` → `/opt/backoffice/scan-switchboard/scan-switchboard.service`
  * Check service status with
    - `systemctl status {service name}`
    - `journalctl --unit {service name}`

* ID3C ETL jobs are run periodically using cron, defined in `/etc/cron.d/backoffice`

* Debug-level ID3C logs are sent to syslog and show up in `/var/log/syslog`.
  `grep` will be helpful in combing through that for just our logs.


### seattleflu.org (“front office”)

_Public- and partner-facing_

Source is <https://github.com/seattleflu/website>.

Hosted on Heroku, pointed to with a DNSimple.com `ALIAS` record.


## Databases (PostgreSQL)

Testing and production instances are entirely separate, and always spell out
explicitly what they are, to reduce the risk of testing impacting production
accidentally.

These are hosted on AWS RDS.

### testing.db.seattleflu.org

* `seattleflu-testing` is the instance name
* db.t2.micro
* primary database is named `testing`

### production.db.seattleflu.org

* `seattleflu-production` is the instance name
* db.t2.micro
* primary database is named `production`

### sqitch configuration
All modifications to databases are handled via [sqitch].
Changes are deployed locally with `sqitch` pointing to the target database.
Deploying changes to remote databases requires some configuration.
* Add connection information to your [password file].
* Update your [connection service file] to something similar to [the connection service file used for Metabase].


## Networking and security groups

* Single AWS VPC

* AWS security group, `web-services`, for web servers allowing ports 80 and 443
  from all and port 22 from Fred Hutch (140.107.0.0/16), UW Medicine, and select
  SFS developers' home IP addresses.

* AWS security group, `rds-postgresql`, for RDS allowing port 5432 from the web
  server security group, the Fred Hutch (140.107.0.0/16), IDM, UW Medicine, and select IDM
  and SFS developers' home IP addresses.


## DNS

Nameservers for seattleflu.org (registered on Hover) use
[DNSimple](https://dnsimple.com).

We stopped using AWS's Route 53 because of issues using a CNAME for the zone
apex (i.e. seattleflu.org).
[More details](https://devcenter.heroku.com/articles/custom-domains#configuring-dns-for-root-domains)


## Email

Email services are provided by [SendGrid](https://sendgrid.com) via their
partnership program with Azure.  We purchase a "silver" subscription, which is
the lowest-priced level that provides a dedicated IP address for the delivering
mail servers.  The account is managed and accessed via the [Azure portal][]
under the "seattleflu" resources group.

Limited, send-only SendGrid API keys are minted for each of our services which
needs to send email.  Currently this includes:

* Postfix on backoffice.seattleflu.org (e.g. for cron job emails)
* Metabase for alerts and "pulses"

Mail for local users on backoffice.seattleflu.org is all aliased to the `root`
user, which is then aliased to outside external addresses, such as those of
individual devs and or Slack channels (via Slack's email integration).

Aliases live in the plain text file `/etc/aliases`.  After editing, you must
run the `newaliases` command as root to update the compiled form.  Refer to
`man aliases` for more information.

Cron sends mail for any job which has output to stdout or stderr, even if the
command exits with success.  (Both [`chronic`][] and [`fatigue`][] are used to
wrap cron job commands to affect this behaviour.)  Mail is sent to the user the
job is running as (usually `ubuntu` for us) or to the value of `MAILTO` if set
in the crontab (usually not for us).


[Azure portal]: https://portal.azure.com
[sqitch]: https://sqitch.org/
[password file]: https://www.postgresql.org/docs/10/libpq-pgpass.html
[connection service file]: https://www.postgresql.org/docs/10/libpq-pgservice.html
[the connection service file used for Metabase]: https://github.com/seattleflu/backoffice/blob/master/pg_service.conf
[`chronic`]: https://joeyh.name/code/moreutils/
[`fatigue`]: https://github.com/tsibley/fatigue
