# SFS/SCAN Data Flow

An outline of the various data flows in Seattle Flu Study (SFS) and Greater Seattle Coronavirus Assessment Network (SCAN)

## Table of Contents
* [Data Ingest](#data-ingest)
    * [Lab Manifest](#lab-manifest)
    * [REDCap](#redcap)
    * [Other Enrollments](#other-enrollment-data-sources)
    * [Molecular Results](#molecular-results)
    * [Genomic Data](#genomic-data)
    * [Outdated](#outdated)
* [ETL](#etl)
* [Data Warehouse](#data-warehouse)
* [Data Export](#data-export)
    * [Metabase](#metabase)
    * [Shipping Schema](#shipping-schema)


## Data Ingest

#### Lab Manifest
The lab at the Brotman Baty Institute (BBI) maintains Excel files that record all samples processed by them.
* Uploaded daily to the Fred Hutch AWS S3 bucket by BBI partners
* [Cronjobs] set up to parse and upload the manifest data to ID3C table `receiving.manifest`
* See detailed script in [specimen-manifest] and [ID3C](https://github.com/seattleflu/id3c/blob/master/lib/id3c/cli/command/manifest.py).

We also use the lab manifest to identify UW retrospective samples that need metadata pulled from the UW EMR system.
When we detect new UW retrospective samples, we upload their data to the SFS - Clinical Data Pull REDCap project.
[ITHS] then helps us pull data from EMR and fills in the records on REDCap.
* [Cronjonbs] set up to parse and upload the UW data to REDCap daily
* See detailed script in [backoffice](https://github.com/seattleflu/backoffice/blob/master/bin/import-uw-retrospectives-to-redcap)

#### REDCap
In Year 2 of SFS, we started to use the [ITHS REDCap] survey tools to collect data from participants.

Each study arm sets up their own REDCap project so they can customize the questions and flow of the survey according
to the needs of the study. Due these differences, we've set up separate ingest processes for all of the
SFS projects. On the other hand, we use a single ingest process for all SCAN projects since they have identical survey fields,
just translated into different languages.

REDCap has a feature called Data Entry Trigger (DET) that will POST minimal data about a record to an API endpoint
when the record is created or updated. However, these do not work for bulk uploaded records or records updated via
the mobile platform. For these cases, we have cronjobs set up to generate DETs for records over a certain time period
and upload them to ID3C (see example in [backoffice](https://github.com/seattleflu/backoffice/blob/master/bin/generate-and-upload-uw-retro-redcap-dets)).

Projects are set up to POST DETs to an [SFS API endpoint] that will upload the data to ID3C table `receiving.redcap_det`.
We use this data to fetch the full records from the REDCap API and transform each record into a [FHIR Bundle].
##### Currently Ingesting:
* SCAN
* UW Retrospectives

##### Paused study arms:
* Kiosk
* Swab&Send + Self-test
* Asymptomatic Swab&Send

##### Not Ingesting:
* Shelters - started as a blind clinical trial that should not be ingested to hide the data from study investigators
* Household Studies - complicated structure of multiple individuals per record with repeating events & instruments
that we just haven't had time to work through


#### Other Enrollment Data Sources
There are other enrollment data sources that have not been converted to REDCap projects:
##### Seattle Children's Hospital (SCH)
* CSV or Excel file uploaded weekly to the Fred Hutch AWS S3 bucket by SCH partners
* [Cronjobs] set up to parse and upload SCH data.
##### Kaiser Permanente (KP)
* CSV uploaded by KP partner to the Kaiser secure file transfer (biannual)
* Requires manual download, parse and upload

Both SCH and KP data are parsed and uploaded to ID3C table `receiving.clinical`
* See detailed script in [ID3C-customizations](https://github.com/seattleflu/id3c-customizations/blob/master/lib/seattleflu/id3c/cli/command/clinical.py).

#### Molecular Results
We receive molecular assay results from multiple sources, with the bulk of them from the Northwest Genomics Center (NWGC).
##### NWGC
* Uses a software called Samplify to POST presence/absence result JSONs to [SFS API endpoint]
* Provides two types of results:
    * Taqman OpenArray for a large panel of respiratory pathogens
    * Taqman QuantStudio PCR (QPCR) for SARS-CoV-2 pathogen detection

##### UW Clinical
* Ingested from the SFS - Clinical Data Pull REDCap project
* Provides results for a panel of respiratory pathogens
* As of March 2020, the data pulls include SARS-CoV-2 results

##### Ellume
* Part of the self-test study arm that provides Ellume self-test kits to participants
* The Ellume team has set up automatic POST of [FHIR Bundle] with [FHIR Diagnostic Report] to [SFS API endpoint]
    * More details at [fhir/presence-absence-example.md]
* Provides results for Influenza A and Influenza B.

##### Cepheid
* Part of the Kiosk study arm that provides rapid diagnostics on-site
* Kiosk staff manually enters the results in the Kiosk REDCap project
* Provides results for Influenza A, Influenza B, and RSV.

#### Genomic Data
##### NWGC
* Uses Illumina sequencing to sequence samples that have tested postive for certain pathogens.
* NWGC partners upload the resulting raw sequence reads to Globus.
* Sequence reads are manually transferred from Globus to [Fred Hutch rhino]
* Requires manual parse and upload of metadata for these sequence read sets
    * see detailed script in [ID3C](https://github.com/seattleflu/id3c/blob/master/lib/id3c/cli/command/sequence_read_set.py)

##### SFS Assembly
* The sequence reads are assembled into consensus genomes using the SFS [assembly] pipeline
* Currently only assembling Influenza and SARS-CoV-2 positive samples.
* The SFS assembly pipeline automatically POSTs complete Influenza genomes to ID3C table `receiving.consensus_genome`
* SARS-CoV-2 genomes are not currently uploaded to ID3C due to the database not set up to limit access to them from the general study group.

#### Outdated:
We have some lingering ingest scripts from Year 1 of SFS that are no longer used.
These will need to be clean up at some point but can be ignore for now.
* UW retrospective - used to be CSV, now moved to REDCap project
* Longitudinal child care data - study arm removed from SFS in Year 2
* Audere enrollments - moved to REDCap projects in Year 2
* Self-test kits - moved to REDCap projects in Year 2

---
## ETL
Each data source has its own ETL process that fetches data from the `receiving` schema of ID3C and uploads the standardized data to the `warehouse` schema of ID3C.

ETL scripts can be found in both [ID3C](https://github.com/seattleflu/id3c/tree/master/lib/id3c/cli/command/etl) and [ID3C-customizations](https://github.com/seattleflu/id3c-customizations/tree/master/lib/seattleflu/id3c/cli/command/etl).

---
## Data Warehouse

See diagram of `warehouse` tables and their relations at [id3c-warehouse-schema.pdf]
Details of the schema can be found in both [ID3C](https://github.com/seattleflu/id3c/tree/master/schema) and [ID3C-customizations](https://github.com/seattleflu/id3c-customizations/tree/master/schema)

---
## Data Export
Data export is handled in two ways: ad-hoc queries via [Metabase] and custom views in the `shipping` schema.

#### Metabase
Metabase is an online tool that provides a nice interface for interacting with data within ID3C.
* Analytics and dashboards can be created without any SQL knowledge
* Complicated SQL queries can be saved to be shared with other users
* Users are put in groups with different levels of access
* A majority of data exports are done through Metabase

#### `Shipping` Schema
Custom views are created in the ID3C `shipping` schema to export data to internal consumers:
* Partners at Institute for Disease Modeling (IDM)
* Return of results to participants
* Notifications for positive SARS-CoV-2 results
* Genomic sequences and metadata for [Augur build]


[assembly]: https://github.com/seattleflu/assembly
[Augur build]: https://github.com/seattleflu/augur-build
[Cronjobs]: https://github.com/seattleflu/backoffice/blob/master/crontabs/id3c-production
[FHIR Bundle]: https://www.hl7.org/fhir/bundle.html
[FHIR Diagnostic Report]: https://www.hl7.org/fhir/diagnosticreport.html
[fhir/presence-absence-example.md]: /fhir/presence-absence-example.md
[Fred Hutch rhino]: https://sciwiki.fredhutch.org/scicomputing/compute_platforms/#rhino
[id3c-warehouse-schema.pdf]: /id3c-warehouse-schema.pdf
[ITHS]: https://www.iths.org/
[ITHS REDCap]: https://www.iths.org/investigators/services/bmi/redcap/
[Metabase]: https://metabase.com
[SFS API endpoint]: https://backoffice.seattleflu.org/production/api
[specimen-manifest]: https://github.com/seattleflu/specimen-manifests
