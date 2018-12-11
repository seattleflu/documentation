# Seattle Flu Study infrastructure

Run by the Bedford Lab, currently managed by Thomas.

Unless noted otherwise, all of this is running under the AWS account
296651737672.


## Route 53

Nameservers for seattleflu.org (registered on Hover)


## EC2

### backoffice.seattleflu.org

_Internal tooling_

* Testing [API](https://github.com/zeXLc2p0/api) at `/testing/api`
* Production [API](https://github.com/zeXLc2p0/api) at `/production/api` (_not yet provisioned_)
* [Metabase](https://metabase.com) at `/metabase` (_not yet provisioned_)

Configuration of interest includes

* Source code (`/opt/api`)

* uWSGI (`/etc/uwsgi`)
    - Apps enabled: `api-testing`
    - App environment using envdirs in `/etc/uwsgi/env.d`

* Apache2 (`/etc/apache2`)
    - Modules enabled: `ssl`, `proxy`, `proxy_uwsgi`
    - Sites enabled: `backoffice`, `backoffice-le-ssl`
    - Reverse proxies to app via uWSGI socket

* Let's Encrypt (`/etc/letsencrypt`)
    - Managed by `certbot`
    - Used by `backoffice-le-ssl` Apache site config
    - Auto-renewing

### frontoffice.seattleflu.org

_Not yet provisioned_

_Public- and partner-facing, serves seattleflu.org_

* Splash page
* Viz (public + protected areas for partners (CDC, PHSKC, etc.))
* "Lookup my swab" for participants


## RDS (PostgreSQL)

Testing and production instances are entirely separate, and always spell out
explicitly what they are, to reduce the risk of testing impacting production
accidentally.

### testing.db.seattleflu.org

* `seattleflu-testing` is the instance name
* db.t2.micro
* primary database is named `testing`

### production.db.seattleflu.org

_Not yet provisioned_

* `seattleflu-production` will be the instance name
* start with db.t2.micro?
* primary database will be named `production`


## VPC and Security groups

* Single VPC

* Security group for web servers allowing ports 80 and 443 from all and port 22
  from Fred Hutch (140.107.0.0/16)

* Security group for RDS allowing port 5432 from web server security group and
  the Fred Hutch (140.107.0.0/16)
