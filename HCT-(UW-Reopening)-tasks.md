# Populating the quota
The clinical team maintains a spreadsheet (link purposefully not put into this wiki because it's public) that sets the quota that the 
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

The rules for inviting participants are documented in the "Quota Logic starting Winter Quarter, January 2021" section at the end of the "UW return-to-campus informatics" document in the Informatics directory of the Google Drive.

We have a Metabase dashboard that shows the invitation queue.  
https://backoffice.seattleflu.org/metabase/dashboard/74

# Updating REDCap records in ID3C

When a clinical user imports into REDCap to update enrollment fields, to mark a participant for a surge, etc., REDCap does not generate change notifications (DETs). Therefore, we need to generate DETs ourselves. Typically, we want to pull in these DETs after 7:00 PM so that we don't drown receiving.redcap_det with these DETs and delay "real time" changes, like daily attestations, that need to be processed so that participants can get invited quickly.

Ask the clinical user the start and stop times of the import. Buffer a couple of minutes on either side and then configure the following command to export DETs. Set the --since-date (the start time), --until-date (the end time), the path to your env dir folder with REDCap entries, and where you want the resulting NDJSON file to get written.

REDCAP_API_URL="https://redcap.iths.org/api/" envdir {path to your env dir folder with REDCap entries} id3c redcap-det generate --project-id=23854 --instrument="enrollment_questionnaire" --since-date="2021-03-05 11:14:00" --until-date="2021-03-05 11:28:00" > enrollment_questionnaire_dets.ndjson

And then import those DETs into the database. Update the following command with production database info and the path to the NDJSON file you generated above. 

PGHOST="{the host}" PGDATABASE="{the database}" PGUSER="{username}" PGPASSWORD=$(read -srep "password: " x; echo "$x")  id3c redcap-det upload enrollment_questionnaire_dets.ndjson
  



