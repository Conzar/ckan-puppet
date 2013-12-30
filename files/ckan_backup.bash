#!/bin/bash
# backs up the database

. /usr/lib/ckan/default/bin/activate
cd /usr/lib/ckan/default/src/ckan
paster db dump --config=/etc/ckan/default/production.ini /backup/ckan_database.pg_dump
