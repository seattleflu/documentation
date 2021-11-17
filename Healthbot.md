# Azure Healthbot

Healthbot data is stored in Azure Storage. It can be viewed and managed using Azure Storage Explorer:
https://azure.microsoft.com/en-us/features/storage-explorer/

## Granting access to study members

*You will need appropriate permissions in Azure to complete these steps*

While it's possible to grant access to tables using only a Shared Access Signature (SAS), it is better to set up a Stored Access Policy (SAP) and then create an SAS assocated to that. This is because SAPs can be manually revoked (effectively revoking any related SASs) but SASs on their own cannot be. They are valid until the end date that is set when they are created.

To grant access to study members, locate the appropriate storage account in Azure Storage Explorer. Browse to the resource you want to grant access to, right-click and choose "Manage Access Policies". For tracking purposes, rename the access policy to include the study member's name after the dash (or first initial + last name) then set a Start time, End time, and Query, Add, Update and/or Delete permissions. Add additional SAPs for each study member you want to grant access to, then press the save button.

Once you have SAP(s) created for a specific resource, right click on the resource again and select "Get Shared Access Signature (SAS)". On the next screen, select the Access Policy (SAP) that you want to associate the SAS with. It will automatically inherit the attributes of the SAP. Press "Create" and copy the URL to send to the study member. Be sure to send it via encrypted email, along with the name of the resource each URL belongs to.  

The study member will need to download and install Azure Storage Explorer as well. To access the data, they will click on the Connect Dialog (plug icon) and select "Storage account or service". Using the "Connection String (Key or SAS)" option, they can paste in the URL that was emailed to them and establish a connection to each individual resource.

## Deploying Survey Changes

The study uses Azure HealthBot, specifically scenario management, to deploy AI-powered, compliant, and conversational surveys for users to take, to determine eligibility for our test kit. Once in a while, the study asks that new questions be added or modified. Once these questions are translated to the appropriate languages (English, Russian, Vietnamese, Traditional Chinese, and Spanish), the changes can be implemented on Azure Healthbot.

Steps to ensuring that questions are added/modified correctly to the survey include:
* Ensuring that all components required are ready.
    *   Documentation on where new questions should go, where modifications go, and where the logic for when to show or skip questions. Typically provided by the designer or the person who asked for these additional/modified questions.
    *   Documentation of the questions and responses, translated to the required languages. Typically provided by the development team's program manager.
    *   These documentations should outline clearly what the asks/needs are. If unclear, it is best to contact the designer for clarifying questions before starting. Direct conversation to the Slack channel, #scan-fall21-bot-survey (or similar channel). 
* Modifying the scenario for the survey of interest
    *   Create a clone of the scenario that is in production. This is where you will make edits. You NEVER want to make changes to the scenario in production.  
    *   Assign new questions variable names and response value labels
        * Naming convention for variable names: [their|your]_[variablenameyoumakeup]_[choiceset|]
        * Naming convention for responses include:
            * suffix: _resp (user’s response where it gets stored)
            * suffix: _other (if there is an other option)
            * suffix: _other_resp (if there is an other response)   
    *   Add questions to the diagram as well as logic branching if needed
        * Typically, these are the green shapes where there may be additional logic added 
    *   Add their and your questions responses
        * Add if the response depend on pronoun 
        * Naming convention: [their|your]_ 
* Add English questions and response to localizations, with variable names (Refer to section below for further details)
* Add responses into build_survey data at the end of diagram 
* Test the bot for English
    *    Make sure that there is no errors.
    *    Ensure that the questions added/modified does not disrupt the survey flow
    *    It is recommended to show the designer this stage of work, to receive any additional feedback 
* Add translation of other languages to localization (Refer to section below for further details)
* Test the HealthBot for the rest of the languages
* Live swap from test to production scenario after testing and QA is done.
    *   Update log writing eventname from test to production scenario
    *   Rename new scenario to the one the production website uses
    *   Archive the test scenario
    
## Implementing Healthbot Translation

To implement the other languages the survey uses, you will need access to the translation document (typically a Google sheet) and Azure HealthBot, specifically Scenario Management. You want to have these two opened on different tabs in your browser.

For the Translation Documentation:
* There are 3 tabs on the sheet: You Your, They Them, and Var Name Root. We are focusing on the first two tabs - You Your and They Them 
* HealthBot makes you flip back and forth between You Your and They Them. 
Tip: Recommend copying the browser URL and opening the two tabs in separate browsers. Be cognizant of using the correct sheet.

Doing the Translations:
* Under HealthBot, go to Language on the left hand corner and click on Localization
* Within the screen, you will need to filter on the question that needs updating/translating work done via the Variable Name Root (column F on the Var Name Root) tab.
* Copy the Variable name root cell, and paste into the expression. This will bring up the question, and the associated language requiring translation.
* Under the appropiate language and under the correct question, copy and paste from the You Your or They Their sheet the translated questions and response to the appropriate cell
    *   Watch out for Your versus Their
    *   It is recommended to first paste the translation into an editor or textpad to ensure that there is the appropriate diacritic on letters are included and there no extra spaces at the beginning and end. 
* Click Save at the top left hand corner
    *   Make sure to consistently save throughout 
    *   Azure HealthBot has about a 30 min timeout window  
*  Utilize this validator to ensure your code is correct: https://jsonformatter.curiousconcept.com/# 
    *   You can copy and paste the entire section to make sure it is valid    

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
