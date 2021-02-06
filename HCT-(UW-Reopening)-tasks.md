# Populating the quota
The clinical team maintains a spreadsheet (link purposefully not put into this wiki because it's public) that sets the quota that the 
offer_uw_testing job should use for each day. The spreadsheet is updated on Fridays to include quota for the next week.

We have a Metabase "Pulse" that will send an alert to the id3c-alerts Slack channel a notification if there is not quota configured for the following day. This alert is a good reminder that quota needs to be configured.

We need to update the operations.test_quota table with the new quota each Friday. In the backoffice repo is some SQL to make this easy. This is in dev/populate-test-quota-sql.txt. It's not a script that you run as-is. Rather, copy and paste from that and run as needed.

If you're adding quota for days that don't already have quota configured, all you need to do is insert. Otherwise, you'll need to delete existing rows so that you can create them again. Do not delete rows for quota entries when some of the quota has actually been used, when "used > 0". Keeping those lets us maintain a complete history of quota that we've used.

The first block of SQL does the inserting. It will insert the daily quota amount (that you find in the spreadsheet in the "Automation" column) divided across the number of hours configured in the SQL. As checked in, this goes from 8:00 AM to 8:00 PM.

In the SQL you will need to update:
daily_quota  : set the value from the Automation column
start_date : set the value for the date corresponding to the quota amount
num_days : set this for the number of days, starting with start_date, that gets the same quota amount. If the whole 7 days has the same amount you'll set this to 7 and just need to run it once. If the first 3 days have one quota amount and the other 4 days have a different amount you would run this twice, adjusting the daily_quota, start_date, and num_days between runs.

You can typically leave start_hour and end_hour as they are. You would change these if you needed to adjust the quota for a day that was inserted previously and had already started to get used.

After you've inserted you can use the next block of SQL to see what's configured for days after today. It will show the total quota (across all hours) for the day. You can compare against the spreadsheet to double check that the right amount got configured. The block of SQL that inserts drops remainder values, so it the quota amount is not evenly divisible by the number of hours you'll see a smaller total number than the quota.





