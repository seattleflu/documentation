## Table of contents

  - [General access to study data](#general-access-to-study-data)
  - [Adding new database users](#adding-new-database-users)
    - [Minting credentials](#minting-credentials)
    - [Accessing the production database](#accessing-the-production-database)
      - [UW Medicine VPN](#uw-medicine-vpn)
      - [Adding your home IP address](#adding-your-home-ip-address)
  - [Adding new REDCap users](#adding-new-redcap-users)
  - [Providing Switchboard access](#providing-switchboard-access)
  - [Providing Fred Hutch S3 access](#providing-fred-hutch-s3-access)
    - [Example IAM policies](#example-iam-policies)
      - [UW / BBI](#uw--bbi)
      - [SCH](#sch)
      - [Swedish](#swedish)


## General access to study data
See [this Slack message](https://seattle-flu-study.slack.com/archives/GJXFQ209K/p1591997617135300?thread_ts=1591997369.134700&cid=GJXFQ209K) pointing to a Google Drive folder, maintained by Robin, that describes access to Metabase, REDCap, etc.

## Adding new database users

### Minting credentials
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
> This will prompt you for your token/password. If you're connecting frequently, you can also setup a password
> file that PostgreSQL can use to remember your password (https://www.postgresql.org/docs/10/libpq-pgpass.html).
>
> Please remember the data usage policies associated with accessing the database, as outlined in the DTUA you signed.
> If you have any questions, the @blab-dev-team can help answer them on the #id3c or #informatics channels in the Seattle Flu Study Slack.

### Accessing the production database
The production database has firewall rules that allow only access to certain IP addresses or IP ranges.
The list of [allowed IP addresses](infrastructure#networking-and-security-groups) is described elsewhere.
Generally speaking, you'll need to be connected to your institution's network (either on campus or via a VPN) to get access to the database.

#### UW Medicine VPN
To use the UW Medicine VPN, you'll need to create an AMC account.
AMC (Academic Medical Center) accounts are used inside UW Medicine to connect to various UW Med resources, including the UW Medicine VPN.
Here is the [info about getting an AMC account](https://services.uwmedicine.org/oip/form/newAccount.jsp).
Your manager/supervisor/department authority should complete the form for you.
Don't submit it for yourself.

Once you get your AMC account, go to [this link to get instructions for installing the VPN client](https://one.uwmedicine.org/sites/its/Networks/Pages/SSLVPN%20Frequently%20Asked%20Questions.aspx).
(You need an AMC account to access this page.)

#### Adding your home IP address
Sometimes, we'll add someone's home IP address to our firewall's allowlist.
To retrieve your public IPv4 address, once connected to your home internet, go to https://www.whatismyip.com/.

## Adding new REDCap users
Before adding a new study member to any REDCap project, confirm the DTUA is executed with Robin.
Then, use [this script](https://github.com/seattleflu/backoffice/blob/master/dev/add-user-to-all-projects) to programmatically import a user to all REDCap with permissions equivalent to an existing REDCap user.

## Providing Switchboard access
Add users in the form of `netid@washington.edu` to the [_authorized-users_ file](https://github.com/seattleflu/backoffice-apache2/blob/master/authorized-users).
Then, `sudo git pull` your new commit into `/etc/apache2` on backoffice.
> Note: You'll need to forward your authentication agent by logging onto the backoffice server with `ssh -A`.

You may need to run `sudo systemctl reload apache2` for apache2 to notice the updated authz users file.


## Providing Fred Hutch S3 access
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

**Note:** if you're granting permissions to a non-Fred Hutch, SFS software developer, consider modifying the above language to something like:
> I'd like to grant them read/write access to all files within the fh-pi-bedford-t/seattleflu object prefix.

When sending an email, be sure to CC the Bedford Lab dev team as well as the study member requesting access.
See the next section for example IAM policies to attach to the email.

### Example IAM policies
#### UW / BBI lab members
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::fh-pi-bedford-t",
      "Condition": {
        "StringLike": {
          "s3:prefix": "seattleflu/*"
        }
      }
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
#### UW / BBI software developers
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::fh-pi-bedford-t",
      "Condition": {
        "StringLike": {
          "s3:prefix": "seattleflu/*"
        }
      }
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
      "Resource": "arn:aws:s3:::fh-pi-bedford-t/seattleflu/*"
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
      "Resource": "arn:aws:s3:::fh-pi-bedford-t",
      "Condition": {
        "StringLike": {
          "s3:prefix": "seattleflu/*"
        }
      }
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
      "Resource": "arn:aws:s3:::fh-pi-bedford-t",
      "Condition": {
        "StringLike": {
          "s3:prefix": "seattleflu/*"
        }
      }
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
