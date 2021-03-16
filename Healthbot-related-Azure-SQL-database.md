Healthbot screener data is copied from Azure Storage to an Azure SQL database so that data can be summarized in Metabase. For example, we use this data to support the visualizations on https://backoffice.seattleflu.org/metabase/dashboard/75 that show the Pierce County traffic through the screener.

Database details:
Azure Portal -> SQL databases
database name: scan (uwbbi/scan)
type: Microsoft SQL Server
The SQL script for the objects in this database is in the backoffice repo in dev/healthbot_azure_sql_database.sql

To manage the database, use Azure Data Studio:
https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio

The screener data includes ZIP code, which is more identifiable that the other data available in Metabase. We have configured the database in Metabase so that general users cannot write or edit queries against this data. 

Azure Data Factory details:
Azure Portal -> Data factories
Data Factory name: bbi



