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
```
Enable pe-postgresql cluster
```
# /vagrant/home/enable_db.sh
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
Switch to pgsql user

```
# pg
master|
```
You can monitor the database log by
```
master| _log
```

* Connect to vm-pgslave

```
$ vagrant ssh vm-pgslave
# sudo tmux attach -d
# ./start-agent.sh
```
Wait for it to finish catalog run, then ^c.
Then switch to pgsql user, and monitor the log
```
# pg
slave| _log
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

* Check WAL

Create new windows with tmux, switch to pgsql user with pg in both master and slave then,

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
