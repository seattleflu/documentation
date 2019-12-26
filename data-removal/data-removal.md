# Data Removal

## Prerequisites
Before you get started, you'll need the following:

* a personal admin account for the production ID3C database.
* a peronal admin account for the testing ID3C database or access to the `postgres`

## Steps for data removal of a participant:
1. Login to the production ID3C database with admin account.
1. Find individual connected to provided sample or collection barcode.
1. Set [psql variable](https://www.postgresql.org/docs/10/app-psql.html#APP-PSQL-VARIABLES) `individual` to the `individual.identifier`
1. Check [delete-individual.sql](./delete-individual.sql) to ensure that it is up-to-date with ID3C `receiving` and `warehouse` schema.

    * Notice this does not delete records from `receiving.presence_absence`. The only identifier those results contain is the sample barcodes for this individual, and these are embedded alongside results for unrelated samples. In order to prevent re-processing the specific sample results later, the script removes the sample and collection identifiers from our `warehouse.identifier`. The presence/absence ETL will ignore/skip such results.

1. Run [delete-individual.sql](./delete-individual.sql) via the `\include` psql meta-command.
1. Run `commit;` after verifying the appropriate records have been deleted.
1. Repeat steps 2-5 on the testing ID3C database or [refresh the testing database](https://github.com/seattleflu/backoffice/blob/master/dev/refresh-database).

## Other stores:
* Notify all devs to remove local copies of database.
* AWS backups of the database naturally expire within a month.
* Notify/check-in with upstream data sources (SCH, UW, BBI, NWGC)
    * The upstream specimen manifest does not need to be changed because the sample and collection identifiers will be removed from our `warehouse.identifier`. The manifest ETL will ignore/skip such results
