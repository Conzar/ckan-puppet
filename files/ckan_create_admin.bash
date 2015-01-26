#!/bin/bash
# creates a user account.

. /usr/lib/ckan/default/bin/activate
cd /usr/lib/ckan/default/src/ckan
paster --plugin=ckan sysadmin add $1 --config=/etc/ckan/default/production.ini
