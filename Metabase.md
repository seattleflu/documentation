# Navigating Metabase

The study uses Metabase to connect data from ID3C into a user-friendly platform. With Metabase, users have access can ask questions or make custom SQL queries about the data, 
and display the answers in a format they prefer; whether it is bar graph or detailed table. 

Note that Metabase does not hold any PII information.

Users can nagivate to Metabase via [this link](https://backoffice.seattleflu.org/metabase/)

## Getting Started

To get started, users need access to the study's specific Metabase. Access is given by the development team, specifically the program manager. 
Note that there is some paperwork and possible training, enabling you to get access. Reach out the Slack channel, #informatics and request access there.

* Take a look around Metabase and get familiarized with the layout and specs. 
  * There is [documentation](https://www.metabase.com/docs/latest/getting-started.html) that Metabase provides on their website on how to get started. This will be the best documentation on how to go about Metabase.
 * Take a peek at Saved questions and see if they align with your questions/asks:
    * [Collection of HCov19-Specific Questions](https://backoffice.seattleflu.org/metabase/collection/311)
    * Commonly-used queries by the lab: 
       *  [Barcode Lookup](https://backoffice.seattleflu.org/metabase/dashboard/45)
       *  [hCoV-19 Tested Samples](https://backoffice.seattleflu.org/metabase/question/479)
       *  [Flu Positive Samples with Other Detected OA Pathogens](https://backoffice.seattleflu.org/metabase/question/710)
       *  [HCT Tested Samples Breakdown](https://backoffice.seattleflu.org/metabase/question/782)
       *  [Orf1 and S Gene Crt Values for HCoV+](https://backoffice.seattleflu.org/metabase/question/732)
* Get familiarized on how ID3C stores its data. Refer to the [warehouse schema](https://github.com/seattleflu/documentation/blob/master/id3c-warehouse-schema.pdf) here as it will be extremely helpful when creating custom PostGresSQL queries.  
    * This schema outlines how identifiers from different warehouse tables are connected to each other.
* Get familiarized with PostGreSQL. This is a language used on Metabase to query the data you need (selecting data, joining tables, sorting result sets, and filtering rows)
* Some helpful tutorials include: [PostgreSQL Tutorial](https://www.postgresqltutorial.com/) or [Select Star SQL](https://selectstarsql.com/)
* Get familiarized with JSON
    * A lot of the information in tables and warehouses are under a column called ‘details’. This column is JSON formatted where there are a lot of key-pair values that otherwise would have their own column.
    * Resources on this topic: [JSON](https://www.postgresql.org/docs/9.3/functions-json.html) or [JSON function and operators](https://www.postgresqltutorial.com/postgresql-json/)

## Creating/Modifying Queries

A good way to get started is to find a saved question most similar to your question and use it as a template. 
From this template, you can make edits and changes easier compared to starting entirely from scratch.

Some questions (but not all) to think about:
* SELECT: what values do you want from a table?
* FROM: where do these values come from (what table)?
* WHERE: is there any filtering such as time period, certain sample_origin, particular test (open array vs Taqman)
* JOIN: do you need values from other tables? If so, join them here via their common identifier
* ORDER BY: is there a particular order you need the query to be? Latest date (DESC)?

With the queries you make, you can save it into a public collection or your own personal collection (no one has access to, but you)

In the case that you are unsure on how to go about and create your queries, please message the channel, #informatics for help and someone can assist you. 
Occasionally, the development team will have office hours, otherwise Slack messages on #informatics work just as well.

## Details on Warehouse Schema and Tables

ID3C ingest data such as REDCap data, sample data from the aliquoting sheet, and presence absence data from Samplify. Based on the processes the development team has in place, 
these types of information are stored in either shipping and receiving tables or warehouses (note that there are others, but not important for this purpose). 

The following tables/warehouses can be found under OUR DATA → PRODUCTION or PRODUCTION (WITH HCOV-19)

* Shipping tables: these tables are created and pre-built by the development team based on what the study asks are. With these pre-built tables, they typically provide information that is useful for at least one part of the study. For queries, use these tables to join if they are available before referring to warehouses.
    * Some common tables include:
        * Presence Absence Result V2
        * SCAN Enrollment V1
        * Uw Reopening Encounters V1
* Receiving tables: data received into ID3C typically before any type of processing is done. It is best to avoid pulling data from these tables as they have not been quality-controlled by ETL processes. 
* Warehouses: If the information is not readily available, the warehouses are where you will find it. 
    * This includes:
        * Presence absence: Information from Samplify
        * Sample: Information from the aliquoting sheet/LIMS
        * Target
        * Site

Refer to this [diagram](https://www.metabase.com/docs/latest/getting-started.html) on further details and how you can use them to join tables in your queries
