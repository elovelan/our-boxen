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
  #nodejs::version { '0.8': }
  #nodejs::version { '0.10': }
  #nodejs::version { '0.12': }

  # default ruby versions
  #ruby::version { '1.9.3': }
  #ruby::version { '2.0.0': }
  #ruby::version { '2.1.8': }
  #ruby::version { '2.2.4': }

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

  # Ensure brew casks is installed
  include brewcask

  # Eric's apps
  include vagrant
  include heroku
  #include postgresql
  include atom
  include docker

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
      # installed manually due to version requirement
      # 'citrix-receiver',
      'ynab',
      'vmware-fusion', # auto
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
      'rescuetime',
      'fiddler',
      'azure-cli',
      'android-file-transfer',
      'steam',
      'jdownloader',
      'vlc'
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
  # DirecTV player
  # onedrive
  # language-puppet for atom
  # network link conditioner aka Hardware IO Tools for Xcode
  # Hardware Monitor Lite
  # atom packages

  nodejs::version { 'io-2': }
  # set default version in hiera
  include nodejs::global

  npm_module { 'yo':
    module       => ['yo'],
    node_version => '*',
  }

  ruby::version { ['1.8','1.9','2.1','2.2']: }
  # this will set the default ruby (has to come AFTER previous line)
  include ruby::global

  ruby_gem { 'bundler':
    gem          => 'bundler',
    ruby_version => '*',
  }
  # for bundle-viz
  # todo: loop or get ruby::version from hiera but exclude 1.8 (not supported)
  ruby_gem { 'ruby-graphviz22':
    gem          => 'ruby-graphviz',
    ruby_version => '2.2',
  }

  ruby_gem { 'puppet-lint':
    gem          => 'puppet-lint',
    ruby_version => '2.2',
    version      => '>=1.1'
  }

  ruby_gem { 'hiera-eyaml-system':
    gem          => 'hiera-eyaml',
    ruby_version => 'system',
  }

  package {
    [
      # requirements for graphviz
      'swig',
      'gettext',
      'pkg-config',
      'graphviz',
      # other packages
      'android-platform-tools',
      'rpm',
      'md5sha1sum',
      'tmux',
      'unrar',
      'xz',
      'dnvm',
    ]:
  }

  ini_setting { 'Citrix KeyboardLayout':
    ensure            => present,
    section           => 'WFClient',
    key_val_separator => '=',
    setting           => 'KeyboardLayout',
    value             => 'US',
    path              => "/Users/elovelan/Library/Application Support/Citrix \
Receiver/Config",
  }

# TODO: this is not yet supported by gfxcardstatus
#   file { 'gfxcardstatus launchd plist':
#     ensure  => present,
#     path    => '/Library/LaunchAgents/com.codykrieger.gfxCardStatus',
#     content => '<?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
#   "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
# <plist version="1.0">
# <dict>
#   <key>Label</key>
#     <string>com.codykrieger.gfxCardStatus</string>
#   <key>ProgramArguments</key>
#     <array>
# 	    <string>/usr/bin/open</string>
# 	    <string>/Users/elovelan/Applications/gfxCardStatus.app</string>
# 	    <string>--integrated</string>
# 	  </array>
#   <key>RunAtLoad</key>
# 	  <true/>
# </dict>
# </plist>
# '
# TODO: set a dep on the gfxCardStatus package
#   }
#   ~>
#   service { 'com.codykrieger.gfxCardStatus': }
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
