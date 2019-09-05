Steps for deployment:
1. Merge the target branch(es) to master
2. Deploy database schema changes via sqitch from your local machine (see [infrastructure](./infrastructure.md), **Making changes to the database**).


        PGUSER={admin acct} sqitch status production
        # check that the plan looks good
        PGUSER=postgres sqitch deploy production

3. Log onto the `backoffice` server.
4. Go to the `id3c` directory and run `git pull`.
5. Add relevant `cron` jobs as necessary.
