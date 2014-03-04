require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # mine
  include skype
  include chrome
  include ntfs_3g
  include vmware_fusion
  include spotify
  include tmux
  include sourcetree
  include evernote
  include vagrant
  include cord
  include fitbit_connect
  include lastpass
  include java
  include java6
  include googlevoiceandvideoplugin
  include xz
  include adobe_reader
  include googledrive
  include virtualbox

  class { 'intellij':
   version => "12.1.6",
   edition => "ultimate",
  }
  # fail if FDE is not enabled
  #if $::root_encrypted == 'no' {
  #  fail('Please enable full disk encryption and try again')
  #}

  # node versions
  #include nodejs::v0_6
  #include nodejs::v0_8
  include nodejs::v0_10_21

  # default ruby versions
  #include ruby::1_8_7
  #include ruby::1_9_2
  #include ruby::1_9_3
  #include ruby::2_0_0

  $rubyver = '2.1.0'  

  class { 'ruby::global':
    version => $rubyver
  }

  # rubygems
  ruby::gem { "veewee for ${rubyver}":
    gem     => 'veewee',
    ruby    => $rubyver
  }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
