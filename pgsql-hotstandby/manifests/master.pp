class devmachine {
  exec { 'apt-get update':
    command => '/usr/bin/apt-get update'
  }

  package { 'vim':
    ensure => 'latest',
  }

  package { 'puppet':
    ensure => 'purged',
  }

  package { 'facter':
    ensure => 'latest',
  }

  package { 'openjdk-7-jdk':
    ensure => 'latest',
  }

  package { 'rake':
    ensure => 'latest',
  }

  package { 'openssh-server':
    ensure => 'latest',
  }

  package { 'git':
    ensure => 'latest',
  }

  package { 'zsh':
    ensure => 'latest',
  }
#  package { 'tmux':
#    ensure => 'latest',
#  }
  package { 'postgresql':
    ensure => 'latest',
  }
  package { 'python-software-properties':
    ensure => 'latest',
  }
  package { 'libpq-dev':
    ensure => 'latest',
  }
  package { 'postgresql-contrib':
    ensure => 'latest',
  }
  package { 'postgresql-server-dev-all':
    ensure => 'latest',
  }
  package { 'libxslt1-dev':
    ensure => 'latest',
  }
  package { 'libpam0g-dev':
    ensure => 'latest',
  }
  package { 'libedit-dev':
    ensure => 'latest',
  }

  package { 'ruby-shadow':
    name => 'libshadow-ruby1.8',
    ensure => 'installed',
  }

 user { 'postgres':
  ensure => 'present',
  comment => "",
  home    => "/var/lib/postgresql",
  shell   => "/bin/bash",
  uid     => 106,
  managehome => 'true',
  password => '$6$TRn.LzNx$t5BuYVGDwKYixYz5SVrjlAsEXkgyIKt7B5pmF/PhmXxOM.0UfPssoJoYfShtUvS8y8Zp6c9DGQzrbueiDDbsh0',
  groups => ['sudo', 'postgres'],
  require => Package['ruby-shadow']
 }

 group { 'postgres':
  gid => "112"
 }


  host { 'vm-postgres-master':
    ensure => 'present',
    ip     => '192.168.33.15',
    target => '/etc/hosts',
    host_aliases => ['vm-postgres-master.vm'],
  }
  host { 'vm-postgres-slave':
    ensure => 'present',
    ip     => '192.168.33.16',
    target => '/etc/hosts',
    host_aliases => ['vm-postgres-slave.vm'],
  }
  exec { "tar":
    command => "tar -xvpf /home/vagrant/x/replication.setup.tar",
    cwd     => "/var/lib/postgresql",
    path    => ["/usr/bin", "/usr/sbin"],
    user => 'postgres',
    refreshonly => true,
    #subscribe => User['postgres'],
  }
  exec { "config_master":
    command => "/var/lib/postgresql/setup/configure_master.sh 192.168.33.15 192.168.33.16",
    cwd     => "/var/lib/postgresql/setup",
    path    => ["/usr/bin", "/usr/sbin"],
    user => 'postgres',
    onlyif => ["test -d /var/lib/postgresql/setup"],
    refreshonly => true,
    subscribe => Exec["tar"],
  }
  exec { '/usr/sbin/usermod -p \'$6$6GK/adSa$dukh/y112W2g56SRyosqv7ztWGNykIFJknzgJA2C0NIgHPw/Vlor/B3uynuz564KZY5EaIpzNzphE2K/PbRx8.\' postgres':
    require => User[postgres];
  }
}

include devmachine

