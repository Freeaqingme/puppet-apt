# = Class: apt::repo::dotdeb
#
# This class installs the dotdeb repo
#
class apt::repo::dotdeb (
  $enable_php55 = false,
  $firewall     = params_lookup('firewall', 'global' )
) {

  case $::operatingsystem {
  Debian: {
    apt::repository { 'dotdeb':
      url        => 'http://packages.dotdeb.org/',
      distro     => $::lsbdistcodename,
      repository => 'all',
      key_url    => 'http://www.dotdeb.org/dotdeb.gpg',
      key        => '4096R/89DF5277',
    }

    if any2bool($enable_php55) {
      apt::repository { 'dotdeb-php55':
        url        => 'http://packages.dotdeb.org',
        distro     => 'wheezy-php55',
        repository => 'all',
        key_url    => 'http://www.dotdeb.org/dotdeb.gpg',
        key        => '4096R/89DF5277',
      }
    }

    if any2bool($firewall) {
      firewall::rule { 'dotdeb-apt':
        protocol        => 'tcp',
        port            => '80',
        destination     => [ 'packages.dotdeb.org', 'www.dotdeb.org' ],
        destination_v6  => [ 'packages.dotdeb.org', 'www.dotdeb.org' ],
        direction       => 'output',
        before          => Service[$::Firewall::Setup::service_name]
      }

      Service[$::Firewall::Setup::service_name] -> Apt::Repository[ 'dotdeb' ]
      if any2bool($enable_php55) {
        Service[$::Firewall::Setup::service_name] -> Apt::Repository[ 'dotdeb-php55' ]
      }
    }

  }
  default: {}
  }

}
