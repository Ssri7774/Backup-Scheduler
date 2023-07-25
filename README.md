# Backup-Scheduler
**This repo is useful to setup the backups of any particular files.** For example, this script is initially setup to take the backup of NetBox database daily, weekly and monthly. Also it only stores 30 days, 12 weeks and 6 months backup files and deletes the older ones.

The script takes the database backup of netbox everyday (you need to select the time in cron job, see below to set up cron job). And then copies the first Monday of the week backup file to weekly directory and then copies the first Monday of the month backup file to monthly directoey.

To manage the storage, I've also included in this script to delete the files from daily directory that are older than 30 days, weekly directory older than 3 months, and monthly directory older than a year. With this kind of backups we can retrive the files or data within days, weeks and months.

**In order to run this script as mentioned above, we need to setup the cron job to run this script everyday at any choice of your time.**

To do that follow the below steps:
1. run the command `crontab -l` to check the existing cronjobs (we can determine whether there are any crons jobs scheduled and make sure not to run mutiple jobs at the same time to aviod conflicts which helps the operating system to manage the load)
2. once determining the time of this script to run. run the command `crontab -e` to edit the cron jobs file
3. if I want to run the job everyday at 6 pm then I enter `0 18 * * * /bin/bash /root/backups/bkp-schdlr.sh` in the new line

*Note: Make sure the path to the script is correct.*

***That's it!!!***


You can not only run this script to take the backups of netbox database but also can be used to run the backups for any files and directories.
To do that you only need to change the below lines in `bkp-schdlr.sh` as per your requirements:
`# Perform daily backup
cd /root/netbox-docker/ && /usr/local/bin/docker-compose exec -T postgres sh -c 'pg_dump -cU $POSTGRES_USER $POSTGRES_DB' | gzip > "$daily_dir/db_dump_$current_date.sql.gz"`
