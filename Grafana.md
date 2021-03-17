The study has a [Grafana Cloud][] subscription on grafana.com, so that we don't
have to manage and operate our own Grafana and Loki instances.

Our [Grafana][] instance is <https://grafana.seattleflu.org>.

Our [Prometheus][] instance on backoffice sends metrics to the Grafana Cloud
account's Prometheus ingestion endpoint, via Prometheus' remote writer support.
The relevant configuration is in our Ansible-managed [infra][].

Soon, `promtail` will send backoffice logs to the Grafana Cloud account's Loki
instance.

Our current "Pro" plan comes with 10 users included.  Additional users are $5
per user per month.


## Authentication

Users can login two ways:

 1. With the UW IdP (via SAML) by clicking the "Login with SAML" button on the
    Grafana login page.  Most users should use this method.

 2. With grafana.com accounts by clicking the "Login with grafana.com" button
    on the login page.  This method should be used only by folks with
    adminstrative access who have grafana.com accounts to manage our
    subscription.  It also provides a backup means of access to monitoring data
    for the dev team if the SAML integration is broken.

Users are matched by email address, so if a grafana.com user has a @uw.edu
email, then they'll be able to login either way.

Contact information, released user attributes, and group-based access control
for the UW IdP's registration record of our Grafana instance can be managed via
the [Service Provider Registry][spreg].


## Authorization

Authz happens in two places:

 1. At the UW IdP, we gate access to Grafana via memberships in the
    `uw_gs_bbi_sfs_grafana` UW Group.  Since Grafana auto-creates new users
    from SAML logins, this allows us to control who from UW can login.  Group
    membership is managed via [UW Groups][] and the access control is
    configured via the [SP registry][spreg].

 2. Within Grafana, we set user roles to control access to creating and
    modifying dashboards and ad-hoc exploration of metrics and logs.  The roles
    are `viewer` (default for new users), `editor`, and `admin`.  These are
    managed via the [Configuration → Users page][grafana-users].


[Grafana Cloud]: https://grafana.com/products/cloud/
[grafana-users]: https://grafana.seattleflu.org/org/users
[infra]: https://github.com/seattleflu/infra
[Prometheus]: https://prometheus.io
[spreg]: https://iam-tools.u.washington.edu/spreg/#mhttps://grafana.seattleflu.org/saml/metadata
[UW Groups]: https://groups.uw.edu
