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
  package { 'postgresql':
    ensure => 'purged',
  }

  #package { 'postgresql92':
  #  ensure => 'latest',
  #}
  #package { 'postgresql92-devel':
  #  ensure => 'latest',
  #}
  #package { 'postgresql92-server':
  #  ensure => 'latest',
  #}
  #package { 'postgresql92-libs':
  #  ensure => 'latest',
  #}
  #package { 'postgresql92-contrib':
  #  ensure => 'latest',
  #}

 user { 'rahul':
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
  exec { '/usr/sbin/usermod -p \'$6$6GK/adSa$dukh/y112W2g56SRyosqv7ztWGNykIFJknzgJA2C0NIgHPw/Vlor/B3uynuz564KZY5EaIpzNzphE2K/PbRx8.\' rahul':
    require => User[rahul]
  }
  file {'/etc/sudoers.d/rahul':
   ensure => file,
   content => 'rahul        ALL=(ALL)       NOPASSWD: ALL
'
  }
}

include devmachine

