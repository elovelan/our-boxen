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
    "${boxen::config::homebrewdir}/bin",
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

  # fail if FDE is not enabled
  #if $::root_encrypted == 'no' {
  #  fail('Please enable full disk encryption and try again')
  #}

  # node versions
  #nodejs::version { 'v0.6': }
  #nodejs::version { 'v0.8': }
  #nodejs::version { 'v0.10': }

  # default ruby versions
  #ruby::version { '1.9.3': }
  #ruby::version { '2.0.0': }
  #ruby::version { '2.1.0': }
  #ruby::version { '2.1.1': }
  #ruby::version { '2.1.2': }

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

  # Eric's apps
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
  include hipchat
  include heroku
  #include postgresql

  class { 'intellij':
    version => "12.1.6",
    edition => "ultimate",
  }

  #postgresql::db { 'mydb': }

  #package { 'silverlight':
  #  provider => 'brewcask'
  #}

  nodejs::version { 'v0.10': }
  $default_nodejs_ver = 'v0.10'
  class { 'nodejs::global': version => $default_nodejs_ver }

  nodejs::module {
    [
      grunt-cli,
      yo,
      generator-chrome-extension
    ]: node_version => $default_nodejs_ver
  }

  ruby::version { '2.1.2': }
  $default_ruby_ver = '2.1.2'
  class { 'ruby::global': version => $default_ruby_ver }

  # rubygems
  ruby::gem { "veewee for ${default_ruby_ver}":
    gem     => 'veewee',
    ruby    => $default_ruby_ver
  }
  ruby::gem { "compass for ${default_ruby_ver}":
    gem     => 'compass',
    ruby    => $default_ruby_ver
  }
  ruby::gem { "netrc for ${default_ruby_ver}":
    gem     => 'netrc',
    ruby    => $default_ruby_ver
  }
  ruby::gem { "heroku-api for ${default_ruby_ver}":
    gem     => 'heroku-api',
    ruby    => $default_ruby_ver
  }

  package {
    [
      'unrar',
    ]:
  }
}
