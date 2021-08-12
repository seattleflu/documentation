# Healthbot

Healthbot data is stored in Azure Storage. It can be viewed and managed using Azure Storage Explorer:
https://azure.microsoft.com/en-us/features/storage-explorer/

## Granting access to study members

*You will need appropriate permissions in Azure to complete these steps*

While it's possible to grant access to tables using only a Shared Access Signature (SAS), it is better to set up a Stored Access Policy (SAP) and then create an SAS assocated to that. This is because SAPs can be manually revoked (effectively revoking any related SASs) but SASs on their own cannot be. They are valid until the end date that is set when they are created.

To grant access to study members, locate the appropriate storage account in Azure Storage Explorer. Browse to the resource you want to grant access to, right-click and choose "Manage Access Policies". For tracking purposes, rename the access policy to include the study member's name after the dash (or first initial + last name) then set a Start time, End time, and Query, Add, Update and/or Delete permissions. Add additional SAPs for each study member you want to grant access to, then press the save button.

Once you have SAP(s) created for a specific resource, right click on the resource again and select "Get Shared Access Signature (SAS)". On the next screen, select the Access Policy (SAP) that you want to associate the SAS with. It will automatically inherit the attributes of the SAP. Press "Create" and copy the URL to send to the study member. Be sure to send it via encrypted email, along with the name of the resource each URL belongs to.  

The study member will need to download and install Azure Storage Explorer as well. To access the data, they will click on the Connect Dialog (plug icon) and select "Storage account or service". Using the "Connection String (Key or SAS)" option, they can paste in the URL that was emailed to them and establish a connection to each individual resource.


# Healthbot-related Azure SQL Database

Healthbot screener data is copied from Azure Storage to an Azure SQL database so that data can be summarized in Metabase. For example, we use this data to support the visualizations on https://backoffice.seattleflu.org/metabase/dashboard/75 that show the Pierce County traffic through the screener.

## Database details

Azure Portal -> SQL databases  
database name: scan (uwbbi/scan)  
type: Microsoft SQL Server  
The SQL script for the objects in this database is in the backoffice repo in dev/healthbot_azure_sql_database.sql

To manage the database, use Azure Data Studio:
https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio

The screener data includes ZIP code, which is more identifiable that the other data available in Metabase. We have configured the database in Metabase so that general users cannot write or edit queries against this data. 

## Azure Data Factory details 
Azure Portal -> Data factories  
Data Factory name: bbi  
pipeline: pipeline_screeningdata  
The pipeline copies data from the screeningdata_azure_storage dataset and inserts it into the screeningdata_sql dataset. It keeps track of rows that it's already copied from screeningdata_azure_storage by updating the watermark entry in the watermark_sql dataset.

