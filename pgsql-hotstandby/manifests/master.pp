class devmachine {
  package { 'facter':
    ensure => 'latest',
  }
  package { 'java-1.7.0-openjdk':
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
  package { 'postgresql-server':
    ensure => 'latest',
  }
  package { 'postgresql-contrib':
    ensure => 'latest',
  }
  package { 'postgresql-devel':
    ensure => 'latest',
  }
  package { 'ruby-shadow':
    ensure => 'installed',
  }

 user { 'postgres':
  ensure => 'present',
  groups => ['wheel', 'postgres'],
 }

 group { 'postgres':
  ensure => 'present',
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
  exec { '/usr/sbin/usermod -p \'$6$6GK/adSa$dukh/y112W2g56SRyosqv7ztWGNykIFJknzgJA2C0NIgHPw/Vlor/B3uynuz564KZY5EaIpzNzphE2K/PbRx8.\' postgres':
    require => User[postgres];
  }
  file {'/etc/sudoers.d/postgres':
   ensure => file,
   content => 'postgres        ALL=(ALL)       NOPASSWD: ALL
'
  }
}

include devmachine

