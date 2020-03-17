# Troubleshooting

Tips for moving forward when things break.

## ETL processes

### Problem: Presence Absence ETL breaks with a `SampleNotFoundError`
This means the specimen manifest sheet (or at least the latest imported copy of it in ID3C) is out of date.
The lab may be slightly behind in updating it, or we may choose to manually import the specimen manifest sheet instead of relying on our automated process to import known specimen manifest sheets from S3.


### Problem: Manifest ETL breaks with an `AssertionError`
```
AssertionError: Collection identifier found in set «samples», not {'collections-environmental', 'collections-kiosks', 'http://collections-seattleflu.org', 'collections-self-test', 'collections-household-intervention', 'collections-swab&send-asymptomatic', 'collections-kiosks-asymptomatic', 'collections-swab&send', 'collections-household-observation', 'http://collections-fluathome.org'}
```

In this case, we need to ask Peter or someone in #lab to update the specimen manifest with new collection IDs.
We may need to generate new ones for them.
See example Slack threads ([1](https://seattle-flu-study.slack.com/archives/CCAEWSFTK/p1583554674022600), [2](https://seattle-flu-study.slack.com/archives/CLCKA5AKW/p1584032284051600)) of how this problem has been resolved previously.


## Metabase

### Problem: Metabase is down

* [Restarting Metabase](https://github.com/seattleflu/backoffice/tree/master/metabase#restart) may help.

### Problem: Metabase queries are slow
* Try adjusting the [Metabase cache](https://www.metabase.com/docs/latest/administration-guide/14-caching.html).
* You can kill long, existing Metabase queries with this bit of SQL:
    ```sql
    select pg_cancel_backend(pid)
    FROM pg_stat_activity
    WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes'
    and usename = 'metabase'
    and state = 'active'
    ```
