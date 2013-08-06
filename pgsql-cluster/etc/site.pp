node 'vm-pgmaster' {
#  class { 'pe_postgresql':
#    node_type => 'master',
#    address   => 'eth1',
#    address_type => 'dev',
#  }
}

node 'vm-pgslave' {
#  class { 'pe_postgresql':
#    node_type => 'slave',
#    address   => 'eth1',
#    address_type => 'dev',
#  }
}

node 'vm-puppetmaster' {

}
