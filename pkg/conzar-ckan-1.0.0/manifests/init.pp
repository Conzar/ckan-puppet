# == Class: ckan
#
# Installs, configures, and manages ckan.
# Install Details: http://docs.ckan.org/en/ckan-2.0/install-from-package.html
#
# Additional features:
# * Database is backed up once a week to /backup/ckan_database.pg_dump.
#
# === Parameters
#
# [*site_url*] The url for the ckan site.
# [*param site_title*] The title of the web site.
# [*site_description*] The description (found in header) of the web site.
# [*site_intro*] The introduction on the landing page.
# [*site_about*] Information on the about page.
# [*plugins*] Contains the ckan plugins to be used by the installation.
# [*site_logo*] The source of the logo.  Should be spedified as
#               puppet:///<your module>/<image>.png 
#               Note, should be a png file.
# [*license*] the source to the json license file.  Should be specified as
#             puppet:///<your module>/<license file> and maintained by your module
# [*is_ckan_from_repo*] A boolean to indicate if the ckan package should be
#                       installed through an already configured repository
#                       setup outside of this module. If using Ubuntu/Deb
#                       should be able to do "apt-get install python-ckan"
#                       Its the same idea for yum and other package managers.
# [*ckan_package_url*] If not using a repo, then this url needs to be
#                      specified with the location to download the package.
#                      Note, this is using dpkg so deb/ubuntu only.
# [*ckan_package_filename*] The filename of the ckan package.
# [*custom_css*] The source to a css file used for the ckan site.  This replaces
#                the default main.css.  Should be specified as
#                puppet:///<your module>/<css filename> and maintained by your module.
#                Note, images used in the custom css should be set in custom_imgs.
# [*custom_imgs*] An array of source for the images to be used by the css.
#                 Should be specified as 
#                 ['puppet:///<your module>/<img1>','...']
#
# === Examples
#
#class { 'ckan':
#  site_url              => 'test.ckan.com',
#  site_title            => 'CKAN Test',
#  site_description      => 'A shared environment for managing Data.',
#  site_intro            => 'A CKAN test installation',
#  site_about            => 'Pilot data catalogue and repository.',
#  plugins               => 'stats text_preview recline_preview datastore resource_proxy pdf_preview',
#  is_ckan_from_repo     => 'false',
#  ckan_package_url      => 'http://packaging.ckan.org/python-ckan_2.1_amd64.deb',
#  ckan_package_filename => 'python-ckan_2.1_amd64.deb',
#}
#
# === Authors
#
# Michael Speth <spethm@landcareresearch.co.nz>
#
# === Copyright
# GPLv3
#
class ckan (
  $site_url,
  $site_title,
  $site_description,
  $site_intro,
  $site_about,
  $plugins,
  $site_logo = '',
  $license = '',
  $is_ckan_from_repo = 'true',
  $ckan_package_url = '',
  $ckan_package_filename = '',
  $custom_css = 'main.css',
  $custom_imgs = '',
){
  $ckan_package_dir = '/usr/local/ckan'

  stage {'va_first':
    before => Stage['first'],
  }

  class { 'reset_apt':
    stage => va_first,
  }

  stage {'first':
    before => Stage['main'],
  }
  class { ckan::repos:
    stage   => first,
    require => Class['reset_apt'],
  }
  class { ckan::install:
    require => Class['ckan::repos'],
  }
  class { 'ckan::db_config':
    require => Class['ckan::install'],
  }
  class { 'ckan::config' :
    site_url         => $ckan::site_url,
    site_title       => $ckan::site_title,
    site_description => $ckan::site_description,
    site_intro       => $ckan::site_intro,
    site_about       => $ckan::site_about,
    site_logo        => $ckan::site_logo,
    plugins          => $ckan::plugins,
    require          => Class['ckan::db_config'],
  }
  class { 'Ckan::Service' :
    require => Class['ckan::config'],
  }
}
