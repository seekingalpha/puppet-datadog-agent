# Class: datadog_agent::integrations::logs
#
# This class will install the necessary configuration for the logs integration.
#
# Parameters:
#   $logs:
#       array of log sources.
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
#  class { 'datadog_agent::integrations::logs' :
#    logs => [
#      {
#        'type' => 'file',
#        'path' => '/var/log/afile.log',
#      },
#      {
#        'type' => 'docker',
#      },
#    ],
# }
#
# Documentation:
# https://docs.datadoghq.com/logs/log_collection
#

class datadog_agent::integrations::logs(
  Array $logs = [],
) {
  $logs.each |$index, $log_source|
    datadog_agent::integrations::log { "log-${index}":
      log_source => $log_source,
    }
  }
}
