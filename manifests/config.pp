# Private class
class monit::config inherits monit {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { '/var/lib/monit':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { 'monit_config_dir':
    ensure  => directory,
    path    => $monit::config_dir,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    purge   => $monit::config_dir_purge,
    recurse => $monit::config_dir_purge,
    require => Package['monit'],
  }

  file { 'monit_config':
    ensure  => file,
    path    => $monit::config_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp('monit/monitrc.epp', {
      check_interval            => $monit::check_interval,
      start_delay               => $monit::start_delay,
      logfile                   => $monit::logfile,
      mailserver                => $monit::mailserver,
      mailformat                => $monit::mailformat,
      alert_emails              => $monit::alert_emails,
      httpd                     => $monit::httpd,
      httpd_port                => $monit::httpd_port,
      httpd_address             => $monit::httpd_address,
      httpd_allow               => $monit::httpd_allow,
      httpd_user                => $monit::httpd_user,
      httpd_password            => $monit::httpd_password_real,
      mmonit_password           => $monit::mmonit_password_real,
      mmonit_address            => $monit::mmonit_address,
      mmonit_https              => $monit::mmonit_https,
      mmonit_without_credential => $monit::mmonit_without_credential,
      config_dir                => $monit::config_dir,
      monit_version_real        => $monit::monit_version_real
    }),
    require => Package['monit'],
  }

}
