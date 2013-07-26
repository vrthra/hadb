export PATH=/usr/lib/postgresql/9.1/bin:$PATH
export PGDATA=$(/usr/lib/postgresql/9.1/bin/psql -Eqtc 'show data_directory')
