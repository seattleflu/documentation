# Seattle Flu Study onboarding

## Adding new database users
Before adding a new study member to the production database, confirm the DTUA is executed with Robin.

Next, create a new user with the `id3c user create` command.

Once you've created new database credentials with the appropriate grants, send them in an encrypted email to the new study member. One way to do this is to [add the word "secure" (unquoted) in the subject](https://centernet.fredhutch.org/content/dam/centernet/u/center-it/Ignite2/Fred%20Hutch%20Email%20Encryption%20Instructions%202018-11-20.pdf).
You may choose to follow the template below:

> secure Seattle Flu Study database credentials
> -----------
>
> I just created an account for your use only to directly access our production database (ID3C).
>
> Your username is $USERNAME.
> Your access token/password is: $PASSWORD
> Please keep these confidential and secure.
>
> There are many ways to connect, but you can use the command-line PostgreSQL client psql to test like this:
>
>     psql --host production.db.seattleflu.org production $USERNAME
>
> This will prompt you for your token/password. If you're connecting frequently, you can also setup a password > file that PostgreSQL can use to remember your password (https://www.postgresql.org/docs/10/libpq-pgpass.html)> .
>
> Please remember the data usage policies associated with accessing the database, as outlined in the DTUA you signed.
> If you have any questions, the @blab-dev-team can help answer them on the #id3c or #informatics channels in the Seattle Flu Study Slack.
