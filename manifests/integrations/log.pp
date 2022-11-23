# Class: datadog_agent::integrations::log
#
# This class will install the necessary configuration for the logs integration.
#
# Parameters:
#   $log_source:
#       Hash representing a log source.
#
# Log Source:
#   $type
#       Type of log input source (tcp / udp / file / docker / journald / windows_event).
#   $service
#       Optional name of the service owning the log.
#   $source
#       Optional attribute that defines which integration is sending the logs.
#   $tags
#       Optional tags that are added to each log collected.
#   $log_processing_rules
#       Optional array of processing rules.
#
# Sample Usage:
#
#  datadog_agent::integrations::logs { 'afile' :
#    log_source => {
#      'type' => 'file',
#      'path' => '/var/log/afile.log',
#    },
# }
#
# Documentation:
# https://docs.datadoghq.com/logs/log_collection
#

define datadog_agent::integrations::log(
  Hash $log_source = {},
) {
  unless $::datadog_agent::_agent_major_version == 5 {
    require ::datadog_agent

    file { "${datadog_agent::params::conf_dir}/logs-${name}.yaml":
      ensure  => file,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_protected_file,
      content => template('datadog_agent/agent-conf.d/logs.yaml.erb'),
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
    }
  }
}
