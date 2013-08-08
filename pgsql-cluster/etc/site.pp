node 'vm-pgmaster' {
#  class { 'pe_postgresql::master':
#    version   => '9.2',
#    myid   => 'eth1',
#    idtype => 'dev',
#    config_hash => {
#       'listen_addresses' => '*',
#    }
#  }
}

node 'vm-pgslave' {
#  class { 'pe_postgresql::slave':
#    version   => '9.2',
#    myid   => 'eth1',
#    idtype => 'dev',
#    config_hash => {
#       'listen_addresses' => '*',
#    }
#  }
}

node 'vm-puppetmaster' {

}
