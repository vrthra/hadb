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

  package { 'openjdk-6-jdk':
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
}

include devmachine

