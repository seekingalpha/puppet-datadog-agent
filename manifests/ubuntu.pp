# Class: datadog_agent::ubuntu
#
# This class contains the DataDog agent installation mechanism for Debian derivatives
#

class datadog_agent::ubuntu(
  Integer $agent_major_version = $datadog_agent::params::default_agent_major_version,
  String $agent_version = $datadog_agent::params::agent_version,
  Optional[String] $agent_repo_uri = undef,
  String $release = $datadog_agent::params::apt_default_release,
  Boolean $skip_apt_key_trusting = false,
  String $agent_flavor = $datadog_agent::params::package_name,
  Optional[Hash[String, String]] $apt_default_keys = {
    'D75CEA17048B9ACBF186794B32637D44F14F620E' => 'https://keys.datadoghq.com/DATADOG_APT_KEY_F14F620E.public',
    'A2923DFF56EDA6E76E55E492D3A80E30382E94DE' => 'https://keys.datadoghq.com/DATADOG_APT_KEY_382E94DE.public',
  },
) inherits datadog_agent::params {

  if $agent_version =~ /^[0-9]+\.[0-9]+\.[0-9]+((?:~|-)[^0-9\s-]+[^-\s]*)?$/ {
    $platform_agent_version = "1:${agent_version}-1"
  }
  else {
    $platform_agent_version = $agent_version
  }

  case $agent_major_version {
    5 : { $repos = 'main' }
    6 : { $repos = '6' }
    7 : { $repos = '7' }
    default: { fail('invalid agent_major_version') }
  }

  if !$skip_apt_key_trusting {
    $apt_default_keys.each |String $key_fingerprint, String $key_url| {
      apt::key { $key_fingerprint:
        source => $key_url,
      }
    }
  }

  if ($agent_repo_uri != undef) {
    $location = $agent_repo_uri
  } else {
    $location = "https://apt.datadoghq.com/"
  }

  apt::source { 'datadog-beta':
    ensure => absent,
  }

  apt::source { 'datadog5':
    ensure => absent,
  }

  apt::source { 'datadog6':
    ensure => absent,
  }

  apt::source { 'datadog':
    comment  => 'Datadog Agent Repository',
    location => $location,
    release  => $release,
    repos    => $repos,
  }

  package { 'datadog-agent-base':
    ensure => absent,
    before => Package[$agent_flavor],
  }

  package { $agent_flavor:
    ensure  => $platform_agent_version,
    require => [Apt::Source['datadog'],
                Class['apt::update']],
  }

  package { 'datadog-signing-keys':
    ensure  => 'latest',
    require => [Apt::Source['datadog'],
                Class['apt::update']],
  }
}
