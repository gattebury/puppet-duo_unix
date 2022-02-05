# == Class: duo_unix::yum
#
# Provides duo_unix for a yum-based environment (e.g. RHEL/CentOS)
#
# === Authors
#
# Mark Stanislav <mstanislav@duosecurity.com>
#
class duo_unix::yum (
  $repo_uri = 'http://pkg.duosecurity.com',
  $repo_mirror = false,
  $repo_mirror_baseurl = '',
  $repo_mirror_gpgkey = '',
  ) {
  $package_state = $::duo_unix::package_version

  case $::operatingsystem {
    # Map Amazon Linux to RedHat equivalent releases
    'Amazon': {
      $repo_os = $::operatingsystem
      $releasever = $::operatingsystemmajrelease ? {
        '2014'  => '6Server',
        default => undef,
      }
    }
    # Map Scientific Linux to CentOS and fix releasever
    'Scientific': {
      $repo_os = 'CentOS'
      $releasever = $::operatingsystemmajrelease
    }
    # Map AlmaLinux to RedHat and fix releasever
    'AlmaLinux': {
      $repo_os = 'RedHat'
      $releasever = $::operatingsystemmajrelease
    }
    # Map Rocky Linux to RedHat and fix releasever
    'Rocky': {
      $repo_os = 'RedHat'
      $releasever = $::operatingsystemmajrelease
    }
    default: {
      $repo_os = $::operatingsystem
      $releasever = '$releasever'
    }
  }

  if $repo_mirror {
    yumrepo { 'duosecurity':
      descr    => 'Duo Security Repository',
      baseurl  => $repo_mirror_baseurl,
      gpgcheck => '1',
      gpgkey   => $repo_mirror_gpgkey,
      enabled  => '1',
    }
  } else {
    yumrepo { 'duosecurity':
      descr    => 'Duo Security Repository',
      baseurl  => "${repo_uri}/${repo_os}/${releasever}/\$basearch",
      gpgcheck => '1',
      gpgkey   => 'https://duo.com/DUO-GPG-PUBLIC-KEY.asc',
      enabled  => '1',
    }
  }

  if $duo_unix::manage_ssh {
    package { 'openssh-server':
      ensure => installed;
    }
  }

  package {  $duo_unix::duo_package:
    ensure  => $package_state,
    require => Yumrepo['duosecurity'];
  }

}
