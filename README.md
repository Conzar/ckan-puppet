# CKAN puppet module

Author: Michael Speth <spethm@landcareresearch.co.nz>

## About

This module installs, configures, and manages ckan.
Customizations such as site logo, about page, license, and
customized css are easily configurable from this module.  
The ckan database is automatically backed up once a week to 
/backup/ckan_database.pg_dump.


## Installation

The module can be obtained from the [Puppet Forge](http://forge.puppetlabs.com/conzar/ckan).  The easiest method for installation is to use the
[puppet-module tool](https://github.com/puppetlabs/puppet-module-tool).  Run the following command from your modulepath:

`puppet-module install conzar/ckan`

## Requirements
In order to get all of the dependencies do the following:

 * puppet module install conzar-ckan

Other Requirements

 * Ubuntu 12.04 Operating System.
 
 Note, Ubuntu 14.04 has been tested and currently doesn't install properly.

## Configuration

There is one class (ckan) that needs to be declared.  The class installs and manages a single instance of ckan.  The ckan class is a paramaterized class and requires some of the parametes to be declared.

### Required Parameters

The parameters listed require declaring.

#### `site_url`
The url for the ckan site.

#### `param site_title`
The title of the web site. 

### `site_description`
The description (found in header) of the web site.

### `site_intro`
The introduction on the landing page.

### `site_about`
Information on the about page.

### `plugins`
Contains the ckan plugins to be used by the installation.
Note,the following plugins have only been tested .

 * stats 
 * text_preview recline_preview 
 * datastore 
 * resource_proxy 
 * pdf_preview

### `app_instance_id`
The secret password for the app instance which is populated in the production.ini file.
Use paster make-config to generate a config file that contains a new password.
Note, there should be a better method of generating the secrets

### `beaker_secret`
The secret password for beaker which is populated in the production.ini file.
Use paster make-config to generate a config file that contains a new password.
Note, there should be a better method of generating the secrets

## Optional Parameters

The parameters listed in this section can optionally be configured.


### `site_logo`
The source of the logo.  The logo format requires a png file.

Should be spedified as
`puppet:///<your module>/<image>.png`

### `license` 
The source to the license file.  The license format requies a json file.
Should be specified as

`puppet:///<your module>/<license file>` and maintained by your module

### `is_ckan_from_repo` 
A boolean to indicate if the ckan package should be
installed through an already configured repository
setup outside of this module. If using Ubuntu/Deb,
should be able to do "apt-get install python-ckan"
Its the same idea for yum and other package managers (untested).

### `ckan_package_url` 
If not using a repo, then this url needs to be
specified with the location to download the package.
Note, this is using dpkg so deb/ubuntu only.

### `ckan_package_filename` 
The filename of the ckan package.

### `custom_css`
The source to a css file used for the ckan site.  This replaces
the default main.css.  Should be specified as

`puppet:///<your module>/<css filename>` and maintained by your module.

Note, images used in the custom css should be set in custom_imgs.

### `custom_imgs`
An array of source for the images to be used by the css.
Only required if the custom_css uses new images.

Should be specified as 
`[ 'puppet:///<your module>/<img1>' , 'puppet:///<your module>/<img2>' , ... ]`

### `recaptcha_publickey` 
The public key for recaptcha (by default not set).

### `recaptcha_privatekey`
The private key for recaptcha (by default not set).

### `max_resource_size` 
The maximum in megabytes a resource upload can be.

### `datapusher_formats` 
File formats that will be pushed to the DataStore by the DataPusher.  
When adding or editing a resource which links to a file in one of these formats, the DataPusher
will automatically try to import its contents to the DataStore.

### `preview_loadable`
Defines the resource formats which should be loaded directly in an iframe tag when previewing 
them if no Data Viewer can preview it. 

Defaults to 'html htm rdf+xml owl+xml xml n3 n-triples turtle plain atom csv tsv rss txt json'

### `text_formats` 
Formats used for the text preview

Defaults to not being set in the configuration (since its an empty string)

### `postgres_pass` 
The password for the postgres user of the database (admin user).

### `pg_hba_conf_defaults` 
True if use the default hbas and false to configure your own.
This module uses puppetlabs/postgresql so this setting informs the postgresql module
that the hba's should be handled outside of this module.  Requires your own hba configuration.


## Manual Configuration

A systems admin account is still required to be created manually.  If using Ubuntu, use the following command:

sudo ckan sysadmin add <username>

## Usage

This section shows example uses of the ckan module.

### Example 1
This example demonstrates the most basic usage of the ckan module.

	class { 'ckan':
	  site_url              => 'test.ckan.com',
	  site_title            => 'CKAN Test',
	  site_description      => 'A shared environment for managing Data.',
	  site_intro            => 'A CKAN test installation',
	  site_about            => 'Pilot data catalogue and repository.',
	  plugins               => 'stats text_preview recline_preview datastore resource_proxy pdf_preview',
      app_instance_id       => '{xxxxxxxxxxxxxxxx}',
      beaker_secret         => 'xxxxxxxxxxxx',
	  is_ckan_from_repo     => 'false',
      ckan_package_url      => 'http://packaging.ckan.org/python-ckan_2.2_amd64.deb',
      ckan_package_filename => 'python-ckan_2.2_amd64.deb',
	}

### Example 2
This example demonstrates a customize the ckan module.


Declaring a class that manages the configuration files.

	class {landcare_ckan::config:
	}

Declaring the ckan module with the customized parameters.

	class { 'ckan':
	  site_url              => 'test.ckan.zen.landcareresearch.co.nz',
	  site_title            => 'Landcare Research Test CKAN Repository',
	  site_description      => 'A shared environment for managing Landcare Research Data.',
	  site_intro            => 'Welcome to the Landcare Research Pilot Data Repository. This is a trial installation of the CKAN software, for us to test ahead of (all going well) a wider company rollout.',
	  site_about            => 'Pilot data catalogue and repository for [Landcare Research] (http://www.landcareresearch.co.nz)',
	  plugins               => 'stats text_preview recline_preview datastore resource_proxy pdf_preview',
      app_instance_id       => '{xxxxxxxxxxxxxxxx}',
      beaker_secret         => 'xxxxxxxxxxxx',
	  site_logo             => $landcare_ckan::config::logo_src,
	  license               => $landcare_ckan::config::license_src,
	  is_ckan_from_repo     => false,
      ckan_package_url      => 'http://packaging.ckan.org/python-ckan_2.2_amd64.deb',
      ckan_package_filename => 'python-ckan_2.2_amd64.deb',
	  custom_css            => $landcare_ckan::config::css_src,
	  custom_imgs           => $landcare_ckan::config::custom_images_array,
	  require               => Class['landcare_ckan::config'],
	}

Class where the customized configuration files are managed

	class landcare_ckan::config {
	  $img_dir = '/usr/lib/ckan/default/src/ckan/ckan/public/base/images'

	  $landcare_src = 'puppet:///modules/landcare_ckan'

	  $css_src = "$landcare_src/custom.css"

	  $background_img_src = "$landcare_src/LCR-ckan-homepage-background.jpg"
	  $custom_images_array = [$background_img_src]

	  $logo_filename = 'lcr_logo_white_sm.png'
	  $logo_src = "$landcare_src/$logo_filename"

	  $license = 'NZ_licenses_ckan.json'
	  $license_src = "$landcare_src/$license"
	}

## Deploying with Vagrant
Vagrant can be used to easily deploy the ckan module for testing or production environments.
Vagrant was used for the development of the ckan module.  

### Vagrantfile
The following content should be copied to a clean Vagrantfile. 
Note, make sure to edit puppet.module_path with a path to
where the ckan module and the ckan module dependencies are located.

        # -*- mode: ruby -*-
        # vi: set ft=ruby :
        Vagrant.configure("2") do |config|
          config.vm.box = "precise64"
          config.vm.box = "ubuntu/precise64"

          config.vm.network "private_network", ip: "192.168.33.10"
          config.vm.provider "virtualbox" do |v| 
            v.memory = 2048
            v.cpus = 1 
          end 

          config.vm.provision :shell, :path => "upgrade-puppet.sh"

          config.vm.provision "puppet" do |puppet|
            puppet.module_path = "</path to modules>/modules/"
            puppet.manifests_path = "manifests"
            puppet.manifest_file  = "test-ckan.pp"
          end 
        end

### test-ckan.pp
This is the file that contains the declaration of the ckan module.
The file test-ckan.pp should be created in project_home/manifests/.

          class { 'ckan':
            site_url              => 'http://192.168.33.10',
            site_title            => 'CKAN Test',
            site_description      => 'A shared environment for managing Data.',
            site_intro            => 'A CKAN test installation',
            site_about            => 'Pilot data catalogue and repository.',
	  		plugins               => 'stats text_preview recline_preview datastore resource_proxy pdf_preview',
            app_instance_id       => '{xxxxxxxxxxxxxxxx}',
            beaker_secret         => 'xxxxxxxxxxxx',
            is_ckan_from_repo     => false,
            ckan_package_url      => 'http://packaging.ckan.org/python-ckan_2.2_amd64.deb',
            ckan_package_filename => 'python-ckan_2.2_amd64.deb',
            pg_hba_conf_defaults  => true,
          }

### upgrade-puppet.sh
This file manages installing the latest puppet from puppetlabs and updates apt-get
The file upgrade-puppet.sh should be created in project_home/ (same directory as the Vagrantfile).

        #!/bin/bash

        DISTRIB_CODENAME=$(lsb_release --codename --short)
        DEB="puppetlabs-release-${DISTRIB_CODENAME}.deb"
        DEB_PROVIDES="/etc/apt/sources.list.d/puppetlabs.list" # Assume that this file's existence means we have the Puppet Labs repo added

        if [ ! -e $DEB_PROVIDES ]
        then
            apt-get install --yes lsb-release
            # Print statement useful for debugging, but automated runs of this will interpret any output as an error
            # print "Could not find $DEB_PROVIDES - fetching and installing $DEB"
            wget -q http://apt.puppetlabs.com/$DEB
            sudo dpkg -i $DEB

            sudo apt-get update
            sudo apt-get install --yes puppet
        fi

### Usage
In the project directory (vagrant directory),
* Run vagrant: vagrant up
* Wait for vagrant to finish deploying and installing ckan
Basically, wait for the console to return.  You will see the following line:

notice: Finished catalog run in 648.91 seconds

* Open a web browser and enter the following url
http://192.168.33.10

## License

GPL version 3

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, [see](http://www.gnu.org/licenses/).
