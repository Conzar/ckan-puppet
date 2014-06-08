# -- main stage --
class { 'ckan':
  site_url              => 'test.ckan.com',
  site_title            => 'CKAN Test',
  site_description      => 'A shared environment for managing Data.',
  site_intro            => 'A CKAN test installation',
  site_about            => 'Pilot data catalogue and repository.',
  plugins               => 'stats text_preview recline_preview datastore resource_proxy pdf_preview',
  is_ckan_from_repo     => false,
  ckan_package_url      => 'http://packaging.ckan.org/python-ckan_2.1_amd64.deb',
  ckan_package_filename => 'python-ckan_2.1_amd64.deb',
}
