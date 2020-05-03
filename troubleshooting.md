# Troubleshooting

Tips for moving forward when things break.

## Table of Contents
* [ETL processes](#etl-processes)
  * [FHIR ETL](#fhir-etl)
  * [Presence Absence ETL](#presence-absence-etl)
  * [Manifest ETL](#manifest-etl)
* [Metabase](#metabase)
* [SCAN RoR PDF generation](#scan-ror-pdf-generation)

## ETL processes

### FHIR ETL
#### Problem: `AssertionError`
```
Aborting with error: Specimen with unexpected «collections-clia-compliance» barcode «aaaaaaaa»
````
This is the wrong type of barcode, so just delete this record.


### Presence Absence ETL
#### Problem: `SampleNotFoundError`
```sh
No sample with identifier «aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa» found
```
This means the specimen manifest sheet (or at least the latest imported copy of it in ID3C) is out of date.
The lab may be slightly behind in updating it, or we may choose to manually import the specimen manifest sheet instead of relying on our automated process to import known specimen manifest sheets from S3.

Sometimes, this error means that there was a duplicate collection barcode for two samples which is noted on the specimen manifest sheet.
One solution here is to manually create samples with just the sample identifiers from the lab's aliquot manifest.
Once the collection barcode duplication issue is resolved, the manifest ETL will pick it up and update the newly created samples.


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
    Assuming we're supposed to actually ingest barcodes from this collection, we need to add a missing collection (e.g. `collections-haarvi`) to the manifest ETL.

    Sometimes we receive barcodes from collections we're not supposed to be ingesting (e.g. `collections-clia-compliance`).
    In that case, Slack someone on the #lab channel about the CLI barcode, and delete the affected rows from `receiving.manifest.`

3.
    ```
    Aborting with error: Sample identifier found in set «samples-haarvi», not {'samples'}
    ```
    This means we've received a sample from a separate study arm that we're not supposed to be ingesting.
    Ask someone in the #lab Slack channel to update these sample identifiers to have a prefix of `_exp` so they won't get ingested in the next manifest upload.
    The original affected records should be deleted from `receiving.manifest`.

### Problem: `Exception`
1.
    ```
    Aborting with error: More than one sample matching sample and/or collection barcodes: [Record(id=118997, identifier='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', collection_identifier='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', encounter_id=416344), Record(id=120434, identifier=None, collection_identifier='cccccccc-cccc-cccc-cccc-cccccccccccc', encounter_id=416344)]
    ```
    This is one of the nefarious problems caused by duplicate barcodes.
    This situation arises when there are two samples associated with an encounter.
    Of the two samples, you should delete the one that does not have any presence-absence results attached to it.
    Then, the manifest ETL will find only one matching sample in the warehouse.
    It is then able to update the collection identifier to the corrected collection identifier.

2.
    ```
    Aborting with error: More than one sample matching sample and/or collection barcodes: [Record(id=122250, identifier=None, collection_identifier='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', encounter_id=418757), Record(id=119610, identifier='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', collection_identifier='cccccccc-cccc-cccc-cccc-cccccccccccc', encounter_id=420854)]
    ```
    This is another duplicate barcodes problem, but more insidious than #1 because these sampes are already linked to two different encounters.

    We've solved this in the past by taking the following steps:
    1. Delete the sample that doesn't have any presence-absence results.
    In this case, it's sample `122250`.
    2. Run the manifest ETL.
    3. Manually upload a DET for the affected REDCap records so they may be linked to the correct encounter and have a sample.

    Note that samples that have not yet been aliquoted will resolve when they're added to the aliquoting manifest.
    In this case, `cccccccc-cccc-cccc-cccc-cccccccccccc` was one of the duplicate barcodes.
    The tangling that occurred here was probably due to the timing of fixes.


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

## SCAN RoR PDF generation

### Problem: PDF generation errors out for specific barcodes
```sh
ERROR Errors were encountered (n=1) during processing of: ['s3://dokku-stack-phi/covid19/results-scan-study/AAAAAAAA-2020-01-01-en.pdf']
```
* This problem is commonly caused by duplicate record IDs in REDCap.
  It is related to a known REDCap bug that ITHS is working to fix.
  If there are duplicate record IDs in or across study arms (e.g. asymptomatic or symptomatic), post a Slack message in the #redcap channel
  describing that there are one or more duplicate `record_id`s causing errors in our results PDF generation.
  Include which REDCap project contains the problem (e.g. English), and tag Misja.
* Rarely, this problem pops up when ID3C failed to create a Specimen resource for a given REDCap record.
  Manually generating a DET for the target REDCap record should resolve this issue.
  If this issue continues to arise, then further debugging of our REDCap ingest process is warranted.
