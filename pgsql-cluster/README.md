Normal Procedure
==================

    $ make init

In case you have a partial git repository of your code, or some thing went wrong, you can also clone
your postgres and pe_postgres repositories under etc.

    $ git clone git@github.com:vrthra/puppetlabs-pe_postgresql.git etc/modules/pe_postgresql
    $ git clone git@github.com:vrthra/puppetlabs-postgresql.git etc/modules/postgresql

You may also have to do "make moduleupdate" if you have old modules checked out from git.
If you have modified modules, do "make clean"
