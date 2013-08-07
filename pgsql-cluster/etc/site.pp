node 'vm-pgmaster' {
#  class { 'pe_postgresql::master':
#    myid   => 'eth1',
#    idtype => 'dev',
#  }
}

node 'vm-pgslave' {
#  class { 'pe_postgresql::slave':
#    myid   => 'eth1',
#    idtype => 'dev',
#  }
}

node 'vm-puppetmaster' {

}
