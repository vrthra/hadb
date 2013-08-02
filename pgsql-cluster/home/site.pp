node 'vm-pgmaster' {
  class { 'pe_postgresql':
    node_type => 'master',
  }
}

node 'vm-pgslave' {
  class { 'pe_postgresql':
    node_type => 'slave',
  }
}
