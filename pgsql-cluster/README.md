Normal Procedure
==================

    $ make init

In case you have a partial git repository of your code, or some thing went wrong, you can also clone
your postgres and pe_postgres repositories under etc.

    $ git clone git@github.com:vrthra/puppetlabs-pe_postgresql.git etc/modules/pe_postgresql
    $ git clone git@github.com:vrthra/puppetlabs-postgresql.git etc/modules/postgresql

You may also have to do "make moduleupdate" if you have old modules checked out from git.
If you have modified modules, do "make clean"

Further steps:

* Connect to vm-puppetmaster

```
$ vagrant ssh vm-puppetmaster
# sudo tmux attach -d
# edit site.pp
```

Remove the comment chars from beginning.
```
# ./restart-master.sh
```
Wait for it to finish the catalog run.


* Connect to vm-pgmaster

```
$ vagrant ssh vm-pgmaster
# sudo tmux attach -d
# ./start-agent.sh
```
Wait for it to finish the catalog run, then ^c.
```
# tail -f /opt/puppet/var/lib/pgsql/9.2/data/pg_log/*.log
```
Take a new window in tmux and switch to pgsql user
you can go back to the log tail window to monitor slave progress
you may have to wait for a minute while the cron kicks off
```
^b c
# pg
master|
```

* Connect to vm-pgslave

```
$ vagrant ssh vm-pgslave
# sudo tmux attach -d
# ./start-agent.sh
```
Wait for it to finish catalog run, then ^c.
```
# tail -f /opt/puppet/var/lib/pgsql/9.2/data/pg_log/*.log
```
You can check the progress of this at the master log console.
At the server, 'No entry present in hba' is normal, but if it takes too long,
inspect '/var/log/cron' for a line that executes
  /opt/puppet/var/lib/pgsql/bin/restart.check
If it has executed already, then check for existance of
  /opt/puppet/var/lib/pgsql/.restart
if it exists, and it takes too long then execute
  /opt/puppet/var/lib/pgsql/bin/restart.check
manually as root.
Wait for 'LOG:  streaming replication successfully connected to primary'
take a new window, and switch to pgsql user (use pg command)
```
^b c
# pg
slave|
```

* Check WAL

```
master| _check_wal
 slave| _check_wal
```
This verifes that receiver process is listening, and wal records are in sync.

* Create a table, and insert a row, verify it is accessible in both.

```
master| _check_sql
 slave| _check_sql
```

* Trigger mastering

```
slave| _promote_to_master
```
It tries to trigger a failover, updates the slave ip to the previous master, and tries to insert a row.

* Trigger remastering

```
master| _back_to_master
```
Shuts down the pe-postgresql service, then brings it up as a standby after updating the db, restarts the service,
triggers a restart in slave
