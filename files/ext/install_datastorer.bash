#!/bin/bash

# activate
. /usr/lib/ckan/default/bin/activate
cd /usr/lib/ckan/default/src/ckan

# install the sources
pip install -e git+git://github.com/ckan/ckanext-datastorer.git#egg=ckanext-datastorer

# install the requirements
pip install -r ckanext-datastorer/pip-requirements.txt