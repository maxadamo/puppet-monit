# == Class: monit
#
class monit (
  Integer[0] $check_interval         = $monit::params::check_interval,
  Boolean $httpd                     = $monit::params::httpd,
  Integer[1, 65535] $httpd_port      = $monit::params::httpd_port,
  String $httpd_address              = $monit::params::httpd_address,
  String $httpd_allow                = $monit::params::httpd_allow,
  String $httpd_user                 = $monit::params::httpd_user,
  Sensitive $httpd_password          = $monit::params::httpd_password,
  Boolean $manage_firewall           = $monit::params::manage_firewall,
  String $package_ensure             = $monit::params::package_ensure,
  String $package_name               = $monit::params::package_name,
  Boolean $service_enable            = $monit::params::service_enable,
  Variant[
    Boolean, Enum[
      'stopped', 'false',
      'running', 'true']
  ] $service_ensure                  = $monit::params::service_ensure,
  Boolean $service_manage            = $monit::params::service_manage,
  String $service_name               = $monit::params::service_name,
  Stdlib::Absolutepath $config_file  = $monit::params::config_file,
  Stdlib::Absolutepath $config_dir   = $monit::params::config_dir,
  Boolean $config_dir_purge          = $monit::params::config_dir_purge,
  Variant[
    Stdlib::Absolutepath,
    Enum['syslog']] $logfile         = $monit::params::logfile,
  Optional[String] $mailserver       = $monit::params::mailserver,
  Optional[Hash] $mailformat         = $monit::params::mailformat,
  Array $alert_emails                = $monit::params::alert_emails,
  Integer[0] $start_delay            = $monit::params::start_delay,
  Optional[String] $mmonit_address   = $monit::params::mmonit_address,
  Boolean $mmonit_https              = $monit::params::mmonit_https,
  Integer[1, 65535]  $mmonit_port    = $monit::params::mmonit_port,
  String $mmonit_user                = $monit::params::mmonit_user,
  Sensitive $mmonit_password         = $monit::params::mmonit_password,
  Boolean $mmonit_without_credential = $monit::params::mmonit_without_credential,
) inherits monit::params {

  # Use the monit_version fact if available, else use the default for the
  # platform.
  if defined('$::monit_version') and $::monit_version {
    $monit_version_real = $::monit_version
  } else {
    $monit_version_real = $monit::params::monit_version
  }

  if($start_delay + 0 > 0 and versioncmp($monit_version_real,'5') < 0) {
    fail("start_delay requires at least Monit 5.0. Detected version is <${monit_version_real}>.")
  }

  anchor { "${module_name}::begin": }
  -> class { "${module_name}::install": }
  -> class { "${module_name}::config": }
  ~> class { "${module_name}::service": }
  -> class { "${module_name}::firewall": }
  -> anchor { "${module_name}::end": }

}
