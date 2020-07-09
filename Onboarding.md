## Table of contents

  - [General access to study data](#general-access-to-study-data)
  - [Adding new database users](#adding-new-database-users)
  - [Providing AWS Access](#providing-aws-access)
    - [Example IAM policies](#example-iam-policies)
      - [UW / BBI](#uw--bbi)
      - [SCH](#sch)
      - [Swedish](#swedish)


## General access to study data
See [this Slack message](https://seattle-flu-study.slack.com/archives/GJXFQ209K/p1591997617135300?thread_ts=1591997369.134700&cid=GJXFQ209K) pointing to a Google Drive folder, maintained by Robin, that describes access to Metabase, REDCap, etc.

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


## Providing AWS Access
Providing study members with access to the Fred Hutch-managed AWS S3 bucket requires sending an email to Fred Hutch Sci Comp (scicomp@fhcrc.org) like the one below:

> External collaboration for Economy Cloud storage
> -----------
> Hi Sci Comp,
>
> Could you grant an external collaborator of ours access to the Bedford
> lab's Economy Cloud S3 bucket (fh-pi-bedford-t)?
>
> {Affiliation} — {Name} <{Email}>
>
> I'd like to restrict access to specific read/write
> operations scoped to specific object prefixes. Attached is the
> respective IAM policy document for {Affiliation}.

When sending an email, be sure to CC the Bedford Lab dev team as well as the study member requesting access.
See the next section for example IAM policies to attach to the email.

### Example IAM policies
#### UW / BBI
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::fh-pi-bedford-t"
    },
    {
      "Sid": "VisualEditor1",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:GetObjectVersion"
      ],
      "Resource": "arn:aws:s3:::fh-pi-bedford-t/seattleflu/bbi/*"
    }
  ]
}
```

#### SCH
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::fh-pi-bedford-t"
    },
    {
      "Sid": "VisualEditor1",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:GetObjectVersion"
      ],
      "Resource": "arn:aws:s3:::fh-pi-bedford-t/seattleflu/sch/*"
    }
  ]
}
```

#### Swedish
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::fh-pi-bedford-t"
    },
    {
      "Sid": "VisualEditor1",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:GetObjectVersion"
      ],
      "Resource": "arn:aws:s3:::fh-pi-bedford-t/seattleflu/swedish/*"
    }
  ]
}
```
