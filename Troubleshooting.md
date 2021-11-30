Tips for moving forward when things break.

- [ETL processes](#etl-processes)
  - [General](#general)
    - [Problem: Unknown barcode](#problem-unknown-barcode)
  - [FHIR ETL](#fhir-etl)
    - [Problem: `AssertionError`](#problem-assertionerror)
  - [Presence Absence ETL](#presence-absence-etl)
    - [Problem: `SampleNotFoundError`](#problem-samplenotfounderror)
    - [Problem: `AssertionError`](#problem-assertionerror-1)
  - [Manifest ETL](#manifest-etl)
    - [Problem: `AssertionError`](#problem-assertionerror-2)
    - [Problem: `Exception`](#problem-exception)
  - [REDCap DET ETL](#redcap-det-etl)
    - [Problem: Duplicate REDCap record ID in a project](#problem-duplicate-redcap-record-id-in-a-project)
    - [Problem: Unknown discharge disposition value](#problem-unknown-discharge-disposition-value)
- [Metabase](#metabase)
  - [Problem: Metabase is down](#problem-metabase-is-down)
  - [Problem: Metabase queries are slow](#problem-metabase-queries-are-slow)
  - [Problem: Metabase results are stale](#problem-metabase-results-are-stale)
- [SCAN RoR PDF generation](#scan-ror-pdf-generation)
  - [Problem: PDF generation errors out for specific barcodes](#problem-pdf-generation-errors-out-for-specific-barcodes)
  - [Problem: REDCap records with duplicated barcodes are dropped](#problem-redcap-records-with-duplicated-barcodes-are-dropped)
- [Presence Absence Results](#presence-absence-results)
  - [Investigating Presence/Absence Results](#investigating-presenceabsence-results)
    - [Problem: Need to investigate results from a specific plate](#problem-need-to-investigate-results-from-a-specific-plate)
  - [Bad Presence/Absence Results Uploaded](#bad-presenceabsence-results-uploaded)
    - [Problem: A plate was swapped](#problem-a-plate-was-swapped)
    - [Problem: A sample was retroactively failed](#problem-a-sample-was-retroactively-failed)
- [Barcode collection sets](#barcode-collection-sets)
  - [Problem: labels for the incorrect collection identifier were used](#problem-labels-for-the-incorrect-collection-identifier-were-used)
- [SFS Switchboard](#sfs-switchboard)
  - [Problem: SFS Switchboard does not load certain barcodes](#problem-sfs-switchboard-does-not-load-certain-barcodes)
- [Software Stack](#software-stack)
  - [Problem: compiling Python 3.6 on MacOS Big Sur](#problem-compiling-python36-bigsur)
- [Linelists](#linelists)
  - [Problem: Linelist didn't run successfully](#problem-linelist-didnt-run-successfully)
- [Huksy Musher](#husky-musher)
  - [Problem: uWGSGI workers available alert](#problem-husky-musher-uwsgi-workers-available)

## ETL processes
### General
#### Problem: Unknown barcode
When encountering an unknown barcode that looks like a typo or a close match to a real barcode, use the [unknown barcode Metabase query] to try to find a possible match.
If the barcode is from the FHIR ETL, identify the underlying REDCap record this barcode belongs to, and add a new card to **#record-troubleshooting** describing the problem.
If the barcode is from a different ETL, Slack **#lab** to prompt them to update the specimen manifest with the correct barcode (whatever it may be).

### FHIR ETL
#### Problem: `AssertionError`
```
Aborting with error: Specimen with unexpected «collections-clia-compliance» barcode «aaaaaaaa»
```
This is the wrong type of barcode, so delete this record and create a new Trello card in **#record-troubleshooting**.
Be sure to tag Peter and Brian (of the lab) on the new card.


### Presence Absence ETL
#### Problem: `SampleNotFoundError`
```sh
No sample with identifier «aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa» found
```
This means that specimen information sent from the LIMS to ID3C is out of date. The lab may just be behind in syncing it. We can prompt them to do so if needed.

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
Find the presence_absence_id/group number by looking for 
```
Rolling back to savepoint presence_absence group {the group number}
````
in /var/log/syslog.

Manually mark the receiving record as skipped like this:
````sql
update receiving.presence_absence
set processing_log = '[
    {
        "status": "manually skipped",
        "revision": {the current revision number of the presence-absence ETL}
    }
]'
where presence_absence_id = {the group number}
````


### Manifest ETL
#### Problem: `AssertionError`
1.
    ```
    AssertionError: Collection identifier found in set «samples», not {'collections-environmental', 'collections-kiosks', 'http://collections-seattleflu.org', 'collections-self-test', 'collections-household-intervention', 'collections-swab&send-asymptomatic', 'collections-kiosks-asymptomatic', 'collections-swab&send', 'collections-household-observation', 'http://collections-fluathome.org'}
    ```

    In this case, we need to ask Peter or someone in **#lab** to update the specimen manifest with new collection IDs.
    We may need to generate new ones for them.
    See example Slack threads ([1](https://seattle-flu-study.slack.com/archives/CCAEWSFTK/p1583554674022600), [2](https://seattle-flu-study.slack.com/archives/CLCKA5AKW/p1584032284051600)) of how this problem has been resolved previously.

2.
    ```
    Aborting with error: Collection identifier found in set «collections-haarvi», not {'collections-household-observation', 'http://collections-seattleflu.org', 'http://collections-fluathome.org', 'collections-household-intervention', 'collections-self-test', 'samples-haarvi', 'collections-environmental', 'collections-kiosks', 'collections-swab&send', 'collections-scan', 'collections-kiosks-asymptomatic', 'collections-swab&send-asymptomatic'}
    ```
    Assuming we're supposed to actually ingest barcodes from this collection, we need to add a missing collection (e.g. `collections-haarvi`) to the manifest ETL.

    Sometimes we receive barcodes from collections we're not supposed to be ingesting (e.g. `collections-clia-compliance`).
    In that case, make a card for the incorrect barcode in #record-troubleshooting, and delete the affected rows from `receiving.manifest.`

3.
    ```
    Aborting with error: Sample identifier found in set «samples-haarvi», not {'samples'}
    ```
    This means we've received a sample from a separate study arm that we're not supposed to be ingesting.
    Ask someone in the **#lab** Slack channel to update these sample identifiers to have a prefix of `_exp` so they won't get ingested in the next manifest upload.
    The original affected records should be deleted from `receiving.manifest`.

#### Problem: `Exception`
1.
    ```
    Aborting with error: More than one sample matching sample and/or collection barcodes: [Record(id=137871, identifier=None, collection_identifier='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', encounter_id=1754975),    Record(id=138045, identifier='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', collection_identifier=None, encounter_id=None)]
    ```
    This error can arise due to incomplete records within the manifest uploaded by the lab team.
    This usually affects a large batch of samples because the lab team completes one plate of samples at a time in the manifest.
    Search the receiving table to find affected records with:
    ```sql
    with error_records as (
        select
            document ->> 'sample' as sample,
            document ->> 'collection' as collection,
            processing_log
        from receiving.manifest
        where received::date between '<date-before-error>'::date and '<date-of-error>'::date
        and document ->> 'collection' is null
    ),

    complete_records as (
        select
            document ->> 'sample' as sample,
            document ->> 'collection' as collection
        from receiving.manifest
        where received::date = '<date-of-error>'::date
        and document ->> 'collection' is not null
    )

    select *
    from warehouse.sample
    where sample_id in
    (
      select distinct(cast(b.plog ->> 'sample_id' as int)) as error_sample_id
      from
      (
        select jsonb_array_elements(a.processing_log) as plog
        from
        (
          select err.processing_log
          from error_records err
          join complete_records comp using (sample)
        ) as a
      ) as b
    where b.plog @> '{"etl":"manifest"}'
    order by cast(b.plog ->> 'sample_id' as int)
    )
    ;
    ```
    Look at the output of that final `select *`. If that looks correct, change the
    `select *` to `delete` to delete the records from the warehouse.sample table.

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
    1. Run the manifest ETL.
    2. Manually upload a DET for the affected REDCap records so they may be linked to the correct encounter and have a sample.

    Note that samples that have not yet been aliquoted will resolve when they're added to the aliquoting manifest.
    In this case, `cccccccc-cccc-cccc-cccc-cccccccccccc` was one of the duplicate barcodes.
    The tangling that occurred here was probably due to the timing of fixes.


### REDCap DET ETL
#### Problem: Duplicate REDCap record ID in a project
```
Found duplicate record id «999» in project 12345.
Duplicate record ids are commonly due to repeating instruments/longitudinal events in REDCap,
which the redcap-det ETL is currently unable to handle.
If your REDCap project does not have repeating instruments or longitudinal events,
then this may be caused by a bug in REDCap.
```

The warning message really says it all.
While this issue doesn't cause this ETL pipeline to fail, we still want to post in the **#record-troubleshooting** Trello board to alert the REDCap team about this problem.
If left unmitigated, duplicate record IDs in REDCap could cause our [return of results PDF generation to fail](#problem-pdf-generation-errors-out-for-specific-barcodes).
Be sure to tag Misja and Sarah (of the REDCap team) in the new card.

Duplicate record IDs are a commonly known REDCap bug, a duplicate record ID across two study arms (e.g. symptomatic and asymptomatic) for the most part is not surprising.
However, if the problem seems especially bizarre -- for example, if every single REDCap record ID in the priority code study arm is a duplicate record ID of another arm -- then send an additional message in the **#redcap** channel notifying Misja and Sarah of the situation.

#### Problem: Unknown discharge disposition value
```
Unknown discharge disposition value «...» for barcode «...».
```
The ETL pipeline attempts to map the raw discharge disposition value (indicating where the patient went upon discharge from the hospital) to a FHIR Encounter.hospitalization.dischargeDisposition code.
This warning indicates that there is no mapping for the raw value and the REDCap DET has been skipped in the ETL process.

If the raw value is a human readable disposition value, add a mapping to the data source specific ETL pipeline code file in the id3c-customizations repository.
For example, for the UW retrospectives pipeline, edit the discharge_disposition function in [this file](https://github.com/seattleflu/id3c-customizations/tree/master/lib/seattleflu/id3c/cli/command/etl/redcap_det_uw_retrospectives.py).

If the raw value isn't a human readable disposition (e.g., is «96») or if you need more information about how to map it, contact Becca at ITHS.
She will research the data issue and generate a correction if necessary.

Once the mapping has been updated and deployed, be sure to manually generate/upload the DETs for th skipped records so that they can be ingested!

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

### Problem: Metabase results are stale
Metabase caching is enabled so that slow queries don't have to be executed every time the question is viewed. A query that takes longer than the `MINIMUM QUERY DURATION` setting to run will get cached.
The global `CACHE TIME-TO-LIVE (TTL) MULTIPLIER` setting controls how long results get cached. 
From Metabase:
   ```
      To determine how long each saved question's cached result should stick around, we take the query's average execution time and multiply 
      that by whatever you input here. So if a query takes on average 2 minutes to run, and you input 10 for your multiplier, its cache entry 
      will persist for 20 minutes.
   ```

This TTL multiplier setting can be overridden for a question by setting a value in the `cache_ttl` column of the `report_card` table in the metabase database.
First, you may need to give your admin database user permissions by connecting as the `postgres` user and running:
   ```sql
   grant metabase to "{your admin user name}"
   ```

Then update the correct row in the `report_card` table. To set a 0 multiplier (to disable caching altogether) for a question run a command like:
   ```sql 
   update report_card
   set cache_ttl = 0
   where name  = '{the name of the question}'
   ```

## SCAN RoR PDF generation

### Problem: PDF generation errors out for specific barcodes
```sh
ERROR Errors were encountered (n=1) during processing of: ['s3://dokku-stack-phi/covid19/results-scan-study/AAAAAAAA-2020-01-01-en.pdf']
```
* This problem is commonly caused by duplicate record IDs in REDCap.
  It is related to a known REDCap bug that ITHS is working to fix.
  If there are duplicate record IDs in or across study arms (e.g. asymptomatic or symptomatic), post a Slack message in the **#redcap** channel
  describing that there are one or more duplicate `record_id`s causing errors in our results PDF generation.
  Include which REDCap project contains the problem (e.g. English), and tag Misja.
* Rarely, this problem pops up when ID3C failed to create a Specimen resource for a given REDCap record.
  Manually generating a DET for the target REDCap record should resolve this issue.
  If this issue continues to arise, then further debugging of our REDCap ingest process is warranted.


### Problem: REDCap records with duplicated barcodes are dropped
```
Dropped 2 REDCap records with duplicated barcodes: ['AAAAAAAA']
```
Until this warning is resolved, it will prevent returning results to the affected study participants.
When you encounter this warning, please create a new Trello card in the **#record-troubleshooting** board, and assign it to:
* Annie if it's a UW Reopening, non lab-related issue, or
* Misja for all other issues

## Presence Absence Results
### Investigating Presence/Absence Results

#### Problem: Need to investigate results from a specific plate
* We do not have plate name/info in a field within the JSONs we get from Samplify.
However it does seem like the controls of each plate has an `investigatorId` that
starts with the plate name (e.g. `BAT-049A*`).
* So if we need to investigate the results we received for a specific plate,
I recommend running the following query to find the presence_absence_id for
the plate. In this example, we are searching for plate `BAT049A`:
  ```sql
  select
      presence_absence_id
  from
    receiving.presence_absence,
    json_to_recordset(document -> 'samples') as s("investigatorId" text)
  where
    "investigatorId" like 'BAT-049A%'
  group by
    presence_absence_id;
  ```

### Bad Presence/Absence Results Uploaded

#### Problem: A plate was swapped
* When this happens, the lab may create new samples and reattach the results to those samples (see an [example in Slack](https://seattle-flu-study.slack.com/archives/CJU8RN2Q6/p1591721735035500)).
* Our ETL would create new presence/absence records for the sample since the `lims_id` is part of the presence/absence identifier.
* The sample record would be associated with both LIMS IDs, and the previous presence/absence results would still exist. A manual deletion of results associated with the original LIMS ID may be necessary.

#### Problem: A sample was retroactively failed
* When this happens, the lab will re-push the entire plate of results with the updated sample results marked as `Fail`.
* Our ETL skips `Fail` results, so we need to manually delete records in ID3C.
  1. Find the sample record within `warehouse.sample` using the collection barcode or sample barcode
  1. Find all result JSON documents containing the sample within `receiving.presence_absence`
    (Hopefully there's only two records: first incorrect one and an updated one)
  1. Download and diff the JSONs to verify that only the affected sample results are different.
      ```sql
      \copy (select document from receiving.presence_absence where presence_absence_id = ...) to 'fileA.json'
      \copy (select document from receiving.presence_absence where presence_absence_id = ...) to 'fileB.json'
      ```
      ```bash
      jq -S . fileA.json > fileA_fmt.json
      jq -S . fileB.json > fileB_fmt.json
      diff fileA_fmt.json fileB_fmt.json
      ```
  1. Delete the incorrect result record(s) for the sample from `warehouse.presence_absence`
  1. Delete the incorrect results JSON document from `receiving.presence_absence` so we don't ingest the incorrect results again when we bump the ETL revision number.


## Barcode collection sets
### Problem: labels for the incorrect collection identifier were used
Sometimes, the wrong barcode collection identifier set labels are used for an in-person enrollment event.
For example, the study may have an event enrolling people in the SCAN In-Person Enrollments REDCap project, but on the way over, an RA accidentally grabbed Asymptomatic Kiosk collection labels instead of SCAN STAVE collection labels.
If this happens, there are a few steps to take to remedy this:
1. Retrieve the list of all affected collection barcodes that need to have their internal identifier set changed to the correct set.
   Following the example above, we want a list of every Asymptomatic Kiosk collection barcode that was accidentally used for SCAN In-Person Enrollments.
   Let's imagine that the affected barcodes are:
   ```
   AAAAAAAA
   BBBBBBBB
   CCCCCCCC
   ```

2. Verify that the given barcodes are of the correct identifier set:
    ```sql
    select distinct
      identifier_set_id
    from
      warehouse.identifier
    where barcode in (
      'AAAAAAAA',
      'BBBBBBBB',
      'CCCCCCCC'
    );
    ```
    If there is only one `identifier_set_id` returned and it matches our expectations (e.g. it is `16` which is the `identifier_set_id` for `collections-kiosks-asymptomatic`), then we may proceed.
    Otherwise, we need to go back to the beginning and make sure we have a correct understanding of the problem.

3. Then, update the collection identifier set IDs of the affected barcodes.
   Make sure to test locally first.
   Assuming the desired `identifier_set_id` is `25` (`collections-scan-kiosks`), our code may look like:
    ```sql
    update
      warehouse.identifier
    set identifier_set_id = 25
    where barcode in (
      'AAAAAAAA',
      'BBBBBBBB',
      'CCCCCCCC'
    );
    ```
4. Now, check the **#id3c-alerts** channel or the processing log in the `receiving` tables to see if any ETL jobs skipped the record because the encounter's collection barcode was not in an expected set.
   For example, the FHIR ETL does not currently support ingesting Asymptomatic Kiosk barcodes.
   If these barcodes were skipped in any ETL job, upload manually generated REDCap DETs for the affected encounters.


## SFS Switchboard
### Problem: SFS Switchboard does not load certain barcodes
Sometimes the SFS Switchboard's database fails to update.
There is hardly a single cause here, so there are a few things to try when this happens.
1. Check the systemd logs with `sudo systemctl status scan-switchboard`
2. Check the journal logs with `sudo journalctl -fu scan-switchboard`
3. Capture the state of the Switchboard data with:
    ```sh
    cd $(mktemp -d)
    ps aux > ps
    cp -rp /opt/scan-switchboard/data .
    ```
Try to capture as much information about the failed state of the service as possible before manually restarting the service for the lab.

To manually restart the service, depending on your problem, you may choose to:
* Manually generate the Switchboard data via
  ```sh
  PIPENV_PIPFILE=/opt/scan-switchboard/Pipfile \
    envdir /opt/backoffice/id3c-production/env.d/redcap-sfs/ \
    envdir /opt/backoffice/id3c-production/env.d/redcap-scan/ \
    pipenv run make -BC /opt/scan-switchboard/
  ```
* Restart the service with `sudo systemctl restart scan-switchboard`

## Software Stack
### Problem: compiling Python 3.6 on MacOS Big Sur
We currently use Python 3.6 in production but it is currently in security-fixes-only support, and neither the Apple Command-line Developer Tools nor Homebrew support Python 3.6 at this point. In addition, attempting to build it on Big Sur fails due to compilation problems. Here is how to fix that build error and get Python 3.6 on Big Sur. Open a Terminal window and do the following (commands to be run are prepended with a `$`):
1. Download Homebrew from https://brew.sh: 
       $ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
2. Install the prerequisite packages (some may be installed as a matter of course for Homebrew):
       $ brew install bzip2 openssl readline sqlite zlib
3. Download Python 3.6.x (currently 3.6.13, but check https://www.python.org/downloads/source/ for the most recent 3.6 update): 
       $ curl -O https://www.python.org/ftp/python/3.6.13/Python-3.6.13.tgz
4. Untar it:
       $ tar xzf Python-3.6.13.tgz
5. `cd` into the new directory:
       $ cd Python-3.6.13
6. Apply this diff to fix the build error:
       diff --git a/Modules/posixmodule.c b/Modules/posixmodule.c
       index 776a3d2..3b91180 100644
       --- a/Modules/posixmodule.c
       +++ b/Modules/posixmodule.c
       @@ -19,7 +19,10 @@
       #  pragma weak lchown
       #  pragma weak statvfs
       #  pragma weak fstatvfs
       -
       +#include <sys/types.h>
       +#include <sys/socket.h>
       +#include <sys/uio.h>
       +#include <copyfile.h>
       #endif /* __APPLE__ */
       #define PY_SSIZE_T_CLEAN
   Save it as `patch.txt` and apply it in the main Python source directory with:
       $ patch -p1 < patch.txt
   Make sure the patch applies cleanly--it's possible that the location will need to be fuzzed (which is probably fine; you should still check it manually) but if it fails, consider these instructions to be broken.
7. Configure the installation with:
       CC=/usr/bin/clang CFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/openssl/include -I/usr/local/opt/ncurses/include -I/usr/local/opt/sqlite/include -I/usr/local/opt/bzip2/include -I/usr/local/opt/readline/include" LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/openssl/lib -L/usr/local/opt/ncurses/lib -L/usr/local/opt/sqlite/lib -L/usr/local/opt/bzip2/lib -L/usr/local/opt/readline/lib" ./configure --prefix=/usr/local/python --enable-optimizations --with-ensurepip
   This command will configure Python 3.6 for placement in `/usr/local/python`; if you want it in a different prefix (which is a good idea, especially if you have multiple versions of Python on your machine), change the `prefix` argument.
8. Build and install it with:
       $ make && make test
       $ make altinstall
9. Now you can access Python 3.6 by running:
       $ /usr/local/python/bin/python3.6
    (of course, change `/usr/local/python` to whatever you set the prefix to in step 7)

And now for the disclaimers. You should only expect these instructions to work with:
- Big Sur 11.4
- Intel Mac
- Python 3.6.13
- Command-Line Developer Tools v12.5.0.0.1.1617976050, as obtained by `pkgutil --pkg-info=com.apple.pkg.CLTools_Executables`

Please don't depend on this for anything resembling production, or use it with important data, or in the development of nuclear weapons.

[unknown barcode Metabase query]: https://backoffice.seattleflu.org/metabase/question/439

## Linelists
### Problem: Linelist didn't run successfully

If we get an alert that the linelist didn't successfully upload to it's destination (e.g. from the /opt/backoffice/bin/wa-doh-linelists/generate script), we need to manually rerun and upload the linelist file.

Once the underlying issue is fixed, one way to do this is to update the [crontab](https://github.com/seattleflu/backoffice/blob/master/crontabs/wa-doh-linelists) on backoffice production instance, and change the time to run in the next few minutes, reinstall the crontab, let it run, verify output, change the time back and reinstall crontab.
If you need to run it on a different date than the original failed run, you will need to update the `--date` parameter to run for the missed day. (note: this crontab is currently set to generate a linelist for the previous day's result) 
One other option is to just run `backoffice/bin/wa-doh-linelists/generate` script locally, passing in appropriate environment variables and parameters.
You can find additional information about running the linelists generating scripts in our [documentation](
https://github.com/seattleflu/documentation/blob/master/Linelists.md)

When the new linelist is uploaded to its destination, post a note in the slack channel #linelist-submissions for visibility.

## Husky Musher
### Problem: uWGSGI workers available alert

If we get an alert that the available uWSGI workers for huksy-musher has dropped to 0, we need to check the status of those workers and reload husky-musher if one or more workers is stuck.

First get the pids of husky-musher worker processes (with the current configuration (11/30/21) there are 3 workers, which should be listed under the parent process):
`ps -auxf | grep musher`

Run `strace` on each worker pid, for example:
`sudo strace -f -p "12702"`

With the current cofiguration (11/30/2021) each worker has 4 threads, each with their own pid, which should be output by `strace`. Check for any threads that are stuck in read state (i.e. `read(4,  <unfinished ...>`), and monitor for a few seconds to see if they remain in that state.

If one or more worker threads is indeed stuck, reload husky-musher:
`sudo systemctl reload uwsgi@husky-musher`

Repeat the steps above to confirm all workers and threads are functioning. 

If a graceful reload does not work, restarting is a more forceful approach:
`sudo systemctl restart uwsgi@husky-musher`
