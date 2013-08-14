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

   $ vagrant ssh vm-puppetmaster
   # sudo tmux attach -d
   # edit site.pp
   > remove the comment chars from beginning.
   # ./restart-master.sh
   > wait for it to finish the catalog run.


 * Connect to vm-pgmaster

   $ vagrant ssh vm-pgmaster
   # sudo tmux attach -d
   # ./start-agent.sh
   > wait for it to finish the catalog run, then ^c.
   # tail -f /opt/puppet/var/lib/pgsql/9.2/data/pg_log/*.log
   > take a new window in tmux and switch to pgsql user
   ^b c
   # pg
   |

 * Connect to vm-pgslave

   $ vagrant ssh vm-pgslave
   # sudo tmux attach -d
   # ./start-agent.sh
   > wait for it to finish catalog run, then ^c.
   # tail -f /opt/puppet/var/lib/pgsql/9.2/data/pg_log/*.log
   > take a new window, and swithc to pgsql user (use pg command)
   ^b c
   # pg
   |

* On master

   | _check_wal

* On slave

   | _check_wal

* On master

   | _check_sql

* On slave

   | _check_sql

* On slave again, trigger mastering

  | _promote_to_master

* On master again, trigger remastering

  | _back_to_master
  > This needs restarting of servie pe-postgresql in slave for hba.

