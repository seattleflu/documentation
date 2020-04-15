# Troubleshooting

Tips for moving forward when things break.

## Table of Contents
* [ETL processes](#etl-processes)
  * [Presence Absence ETL](#presence-absence-etl)
  * [Manifest ETL](#manifest-etl)
* [Metabase](#metabase)

## ETL processes

### Presence Absence ETL
#### Problem: `SampleNotFoundError`
This means the specimen manifest sheet (or at least the latest imported copy of it in ID3C) is out of date.
The lab may be slightly behind in updating it, or we may choose to manually import the specimen manifest sheet instead of relying on our automated process to import known specimen manifest sheets from S3.


#### Problem: `AssertionError`
```
Aborting with error: Identifier found in set «samples-haarvi», not «samples»
```
This error means that a sample from a separate study arm that we're not supposed to be ingesting was not properly marked as experimental (`_exp`), so it ended up in our pipeline.
The appropriate avenue is to Slack someone in one of data-transfer channels.
We can ask NWGC to re-send the same JSON bundle but with `_exp` designations on the affected samples.
We should manually skip the bundle in `recieving.presence_absence` and wait for the updated JSON.


### Manifest ETL
#### Problem: `AssertionError`
1.
    ```
    AssertionError: Collection identifier found in set «samples», not {'collections-environmental', 'collections-kiosks', 'http://collections-seattleflu.org', 'collections-self-test', 'collections-household-intervention', 'collections-swab&send-asymptomatic', 'collections-kiosks-asymptomatic', 'collections-swab&send', 'collections-household-observation', 'http://collections-fluathome.org'}
    ```

    In this case, we need to ask Peter or someone in #lab to update the specimen manifest with new collection IDs.
    We may need to generate new ones for them.
    See example Slack threads ([1](https://seattle-flu-study.slack.com/archives/CCAEWSFTK/p1583554674022600), [2](https://seattle-flu-study.slack.com/archives/CLCKA5AKW/p1584032284051600)) of how this problem has been resolved previously.

2.
    ```
    Aborting with error: Collection identifier found in set «collections-haarvi», not {'collections-household-observation', 'http://collections-seattleflu.org', 'http://collections-fluathome.org', 'collections-household-intervention', 'collections-self-test', 'samples-haarvi', 'collections-environmental', 'collections-kiosks', 'collections-swab&send', 'collections-scan', 'collections-kiosks-asymptomatic', 'collections-swab&send-asymptomatic'}
    ```
    In this case, we need to add a missing collection (e.g. `collections-haarvi`) to the manifest ETL.

3.
    ```
    Aborting with error: Sample identifier found in set «samples-haarvi», not {'samples'}
    ```
    This means we've received a sample from a separate study arm that we're not supposed to be ingesting.
    Ask someone in the #lab Slack channel to update these sample identifiers to have a prefix of `_exp` so they won't get ingested in the next manifest upload.
    The original affected records should be deleted from `receiving.manifest`.

## Metabase

### Problem: Metabase is down

* [Restarting Metabase](https://github.com/seattleflu/backoffice/tree/master/metabase#restart) may help.
* If restarting Metabase fails, you can check its Docker container status with:
  ```sh
  docker container ls -a
  ```

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
