Healthbot screener data is copied from Azure Storage to an Azure SQL database so that data can be summarized in Metabase. For example, we use this data to support the visualizations on https://backoffice.seattleflu.org/metabase/dashboard/75 that show the Pierce County traffic through the screener.

Database details:
Azure Portal -> SQL Databases
database name: scan
type: Microsoft SQL Server
The SQL for the objects in this database is in the backoffice repo in dev/healthbot_azure_sql_database.sql

To manage the database, use Azure Data Studio:
https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio

The screener data includes ZIP code, which is more identifiable that the other data available in Metabase.We have configured the data set in Metabase so that general users cannot query the data directly. 

Azure Data Factory details:
Data Factory instance: bbi



