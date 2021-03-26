# Populating the quota
The clinical team maintains a spreadsheet (link purposefully not put into this wiki because it's public, see Slack thread https://seattle-flu-study.slack.com/archives/C018V0WGGJ0/p1616786475040200) that sets the quota that the 
offer_uw_testing job should use for each day. The spreadsheet is updated on Fridays to include quota for the next week.

We have a Metabase "Pulse" that will send an alert to the id3c-alerts Slack channel a notification if there is no quota configured for the following day. This alert is a good reminder that quota needs to be configured.

We need to update the operations.test_quota table with the new quota information. In the backoffice repo is some SQL to make this easy. This is in dev/populate-test-quota-sql.txt. It's not a script that you run as-is. Rather, copy and paste from that and run as needed.

If you're adding quota for days that don't already have quota configured, all you need to do is insert. Otherwise, you'll need to delete existing rows so that you can create them again. Do not delete rows for quota entries when some of the quota has actually been used, when "used > 0". Keeping those lets us maintain a complete history of quota that we've used.

The first block of SQL does the inserting. It will insert the daily quota amount (that you find in the spreadsheet in the "Automation" column) divided across the number of hours configured in the SQL. As checked in, this goes from 8:00 AM to 8:00 PM, which is our standard invitation hours.

In the SQL you will need to update:  
daily_quota  : set the value from the Automation column  
start_date : set the value for the first date to get the `daily_quota` amount of quota   
num_days : set this for the number of days, starting with start_date, that gets the same quota amount. If the whole 7 days has the same amount, you'll set this to 7 and need to run the insert SQL only once. If the first 3 days have one quota amount and the other 4 days have a different amount you would run this twice, adjusting the daily_quota, start_date, and num_days between runs.

You can typically leave start_hour and end_hour as they are. You would change these if you needed to adjust the quota for a day that was inserted previously and had already started to get used.

After you've inserted, you can use the next block of SQL to see what's configured for days after today. It will show the total quota (across all hours) for the day. You can compare against the spreadsheet to double check that the right amount got configured. The block of SQL that inserts drops remainder values, so if the quota amount is not evenly divisible by the number of hours, you'll see a smaller total number than the quota.

The SQL to insert quota rounds down to the nearest integer, so if the daily quota amount is not evenly divisible by the number of hours configured for the day then the sum of the quota configured per hour will be less than the daily quota amount. For example, if the daily quota is 2000 and the quota gets divided among 12 hours then each hour gets 166. The total across the hours (166 * 12 = 1992) is less than the original 2000.

The rules for inviting participants are documented in the "Quota Logic starting Winter Quarter, January 2021" section at the end of the "UW return-to-campus informatics" document in the Informatics directory of the Google Drive.

This Metabase dashboard shows the current invitation queue as well as the quota information starting with the current date.   
https://backoffice.seattleflu.org/metabase/dashboard/74

# Updating REDCap records in ID3C

When a clinical user imports into REDCap to update enrollment fields, to mark a participant for a surge, etc., REDCap does not generate change notifications (DETs). Therefore, we need to generate DETs ourselves. Typically, we want to pull in these DETs after 7:00 PM so that we don't drown receiving.redcap_det with these DETs and delay "real time" changes, like daily attestations, that need to be processed so that participants can get invited quickly.

Ask the clinical user the start and stop times of the import. Buffer a couple of minutes on either side and then configure the following command to export DETs. Set the --since-date (the start time), --until-date (the end time), the path to your env dir folder with REDCap entries, and where you want the resulting NDJSON file to get written.

REDCAP_API_URL="https://redcap.iths.org/api/" envdir {path to your env dir folder with REDCap entries} id3c redcap-det generate --project-id=23854 --instrument="enrollment_questionnaire" --since-date="2021-03-05 11:14:00" --until-date="2021-03-05 11:28:00" > enrollment_questionnaire_dets.ndjson

And then import those DETs into the database. Update the following command with production database info and the path to the NDJSON file you generated above. 

PGHOST="{the host}" PGDATABASE="{the database}" PGUSER="{username}" PGPASSWORD=$(read -srep "password: " x; echo "$x")  id3c redcap-det upload enrollment_questionnaire_dets.ndjson

# Looking at the REDCap log for a record
The HCT project contains a lot of data and a lot of records. This makes it really hard to use the log viewer in REDCap to see activity for a given record. Instead, you can just form the URL yourself and go there directly.  
<div style="display: inline">https://redcap.iths.org/redcap_v10.5.2/Logging/index.php?pid=23854&record={the record ID}</div>
  
# Handling a deleted REDCap record
If a REDCap record gets deleted after the enrollment questionnaire was marked as Complete (thus letting our ETL process it) then we will need to delete records on our side. Otherwise, we could continue to invite the participant (the record) for testing. Doing this would actually re-create the REDCap record.
1. If the offers job did re-create the REDCap record, delete that record in REDCap.
2. Delete all encounter_locations for the record ID. Replace "xxxx" with the actual REDCap record ID.
```sql
delete
from warehouse.encounter_location
where encounter_id in
(
select encounter_id
from warehouse.encounter
where details @> '{"_provenance": {"redcap": {"url": "https://redcap.iths.org/", "project_id":23854, "record_id":"xxxx"}}}'
);
```
3. Delete all encounters for the record ID. Replace "xxxx" with the actual REDCap record ID.
```sql
delete
from warehouse.encounter
where encounter_id in
(
select encounter_id
from warehouse.encounter
where details @> '{"_provenance": {"redcap": {"url": "https://redcap.iths.org/", "project_id":23854, "record_id":"xxxx"}}}'
);
```
Open questions: 
1. warehouse.sample's encounter_id column has a foreign key relationship to the encounters table. If we have a sample for the encounter we're trying to delete we won't be able to delete the encounter. Should we null out the encounter_id on those sample rows? Should we delete the sample rows? Should we update the warehouse.sample’s encounter_id to reference an encounter for the retained redcap record?

2. The receiving.fhir records contain the encounters that we just deleted. If we ever reprocess those then the encounters will get re-created. It would be cleaner to find and delete the related FHIR records, but there will be lots.

