#!/bin/bash
# setups up the environment and
# calls the ckanapi command line tool

. /usr/lib/ckan/default/bin/activate
cd /usr/lib/ckan/default/src/ckan
ckanapi --config=/etc/ckan/default/production.ini "$@"