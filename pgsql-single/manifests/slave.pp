define add_user ( $name, $uid, $groups) {
 $homedir = '/home'
 $username = $title
 user { $username:
  ensure => 'present',
  comment => "$name",
  home    => "$homedir/$username",
  shell   => "/usr/bin/zsh",
  uid     => $uid,
  gid => $uid,
  managehome => 'true',
  password => '$1$T2kJF6Jp$ndO.N1uzNORFXRzgWR1ua0',
  groups => $groups
 }

 group { $username:
  gid => "$uid"
 }
}
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
  package { 'tmux':
    ensure => 'latest',
  }
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
  add_user { 'rahul':
    name    => "Rahul",
    uid      => "777",
    groups => ['sudo', 'rahul'],
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
  exec { "configure_slave":
    command => "/var/lib/postgresql/setup/configure_slave.sh 192.168.33.15 192.168.33.16",
    cwd     => "/var/lib/postgresql/setup",
    path    => ["/usr/bin", "/usr/sbin"],
    user => 'postgres',
    onlyif => ["test -d /var/lib/postgresql/setup"],
    refreshonly => true,
    subscribe => Exec["tar"],
  }
}

include devmachine

