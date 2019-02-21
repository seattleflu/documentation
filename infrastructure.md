# Seattle Flu Study infrastructure

Run by the Bedford Lab, currently managed mostly by Thomas.

Unless noted otherwise, all of this is running under the AWS account
296651737672.


## Web hosts

### backoffice.seattleflu.org

_Internal tooling_

* Testing [API](https://github.com/zeXLc2p0/api) at `/testing/api`
* Production [API](https://github.com/zeXLc2p0/api) at `/production/api`
* [Metabase](https://metabase.com) at `/metabase`
* [Lab Labels](https://github.com/tsibley/Lab-Labels) at `/labels`

Hosted on an EC2 instance.

Configuration of interest includes

* [Webpage source and service configs](https://github.com/zeXLc2p0/backoffice) (`/opt/backoffice`)

* [API source code](https://github.com/zeXLc2p0/api) (`/opt/api-testing`, `/opt/api-production`)

* [Metabase container config and data](https://github.com/zeXLc2p0/backoffice/tree/metabase) (`/opt/backoffice/metabase`)

* [Lab Labels container config](https://github.com/zeXLc2p0/backoffice/tree/lab-labels) (`/opt/backoffice/lab-labels`)

* uWSGI (`/etc/uwsgi`)
    - Apps enabled: `api-testing`, `api-production`
    - App environment using envdirs in `/etc/uwsgi/env.d`

* Apache2 (`/etc/apache2`)
    - Modules enabled: `ssl`, `proxy`, `proxy_uwsgi`
    - Sites enabled: `backoffice`, `backoffice-le-ssl`
    - Reverse proxies to API via uWSGI socket
    - Reverse proxies to Metabase via HTTP

* Let's Encrypt (`/etc/letsencrypt`)
    - Managed by `certbot`
    - Used by `backoffice-le-ssl` Apache site config
    - Auto-renewing

* Docker
    - `metabase` container defined using `/opt/backoffice/metabase/create-container`
    - `lab-labels` container defined using `/opt/backoffice/lab-labels/create-container`
    - run via systemd

* systemd
    - `systemctl status metabase`
    - `/etc/systemd/system/metabase.service` → `/opt/backoffice/metabase/metabase.service`
    - `/etc/systemd/system/lab-labels.service` → `/opt/backoffice/lab-labels/lab-labels.service`


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


## Networking and security groups

* Single AWS VPC

* AWS security group for web servers allowing ports 80 and 443 from all and
  port 22 from Fred Hutch (140.107.0.0/16)

* AWS security group for RDS allowing port 5432 from web server security group
  and the Fred Hutch (140.107.0.0/16)


## DNSimple.com

Nameservers for seattleflu.org (registered on Hover).

We stopped using AWS's Route 53 because of issues using a CNAME for the zone
apex (i.e. seattleflu.org).
[More details](https://devcenter.heroku.com/articles/custom-domains#configuring-dns-for-root-domains)
