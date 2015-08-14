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

  # Eric's stuff (split to another file!)

  # Eric's apps
  include vagrant
  include heroku
  #include postgresql
  include atom
  #include docker

  #postgresql::db { 'mydb': }

  package {
    [
      'silverlight',
      'google-chrome',
      'google-drive',
      'mumble',
      'skype',
      'sourcetree',
      'spotify',
      'flowdock',
      'visual-studio-code',
      'flux',
      'mediainfo',
      'mplayer-osx-extended',
      'citrix-receiver',
      'ynab',
      'vmware-fusion',
      'smcfancontrol',
      'logitech-harmony',
      # 'tomighty',
      'lastpass',
      'virtualbox',
      'box-sync',
      'dropbox',
      'flash',
      'usb-overdrive',
      'evernote',
      'google-hangouts',
      'java',
    ]: provider => 'brewcask'
  }

  elove::brew {
    [
      'ntfs-3g'
    ]: tap => 'homebrew/fuse'
  }

  # Other apps:
  # BodyMedia
  # Synergy
  # Akamai NetSession

  nodejs::version { 'v0.10': }
  $default_nodejs_ver = 'v0.10'
  class { 'nodejs::global': version => $default_nodejs_ver }

  ruby::version { ['1.8','1.9','2.1','2.2']: }
  # this will set the default ruby (has to come AFTER previous line)
  include ruby::global

  ruby_gem { 'bundler':
    gem          => 'bundler',
    ruby_version => '*',
  }
  # for bundle-viz
  # todo: loop or get ruby_version from hiera?
  ruby_gem { 'ruby22-graphviz':
    gem          => 'ruby-graphviz',
    ruby_version => 2.2,
  }

  package {
    [
      # requirements for graphviz
      'swig',
      'gettext',
      'pkg-config',
      'graphviz',
      # other packages
      'rpm',
      'tmux',
      'unrar',
      'xz',
    ]:
  }
}

define elove::brew(
  $tap,
  $provider = 'homebrew'
) {
  homebrew::tap { "${tap}": } ->
  package {
    "${name}": provider => $provider
  }
}
