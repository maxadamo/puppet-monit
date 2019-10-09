# == Class: monit
#
class monit (
  Integer[0] $check_interval         = $monit::params::check_interval,
  Boolean $httpd                     = $monit::params::httpd,
  Integer[1, 65535] $httpd_port      = $monit::params::httpd_port,
  String $httpd_address              = $monit::params::httpd_address,
  String $httpd_allow                = $monit::params::httpd_allow,
  String $httpd_user                 = $monit::params::httpd_user,
  Boolean $manage_firewall           = $monit::params::manage_firewall,
  String $package_ensure             = $monit::params::package_ensure,
  String $package_name               = $monit::params::package_name,
  Boolean $service_enable            = $monit::params::service_enable,
  Variant[
    Boolean, Enum[
      'stopped', false,
      'running', true]
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
  Boolean $mmonit_without_credential = $monit::params::mmonit_without_credential,
  Variant[Sensitive, String] $httpd_password  = $monit::params::httpd_password,
  Variant[Sensitive, String] $mmonit_password = $monit::params::mmonit_password,
) inherits monit::params {

  # check if we are either using Sensitive and if we are using the default password
  if $httpd_password =~ String {
    notify { '"httpd_password" String detected!':
      message => 'It is advisable to use the Sensitive datatype for "httpd_password"';
    }
    if $httpd_password == 'monit' {
      notify { '"httpd_password" Default password detected!':
        message => 'It is advisable to not use the default value "httpd_password"';
      }
    }
    $httpd_password_real = Sensitive($httpd_password)
  } else {
    if $httpd_password.unwrap == 'monit' {
      notify { '"httpd_password" Default password detected!':
        message => 'It is advisable to not use the default value for "httpd_password"';
      }
    }
    $httpd_password_real = $httpd_password
  }

  if $mmonit_password =~ String {
    notify { '"mmonit_password" String detected!':
      message => 'It is advisable to use the Sensitive datatype for "mmonit_password"';
    }
    if $mmonit_password == 'monit' {
      notify { '"httpd_password" Default password detected!':
        message => 'It is advisable to not use the default value for "mmonit_password"';
      }
    }
    $mmonit_password_real = Sensitive($mmonit_password)
  } else {
    if $mmonit_password.unwrap == 'monit' {
      notify { '"mmonit_password" Default password detected!':
        message => 'It is advisable to not use the default value "mmonit_password"';
      }
    }
    $mmonit_password_real = $mmonit_password
  }

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
