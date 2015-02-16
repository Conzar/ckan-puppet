#!/bin/bash

# Collects the plugins in the plugins directory
# and writes to the plugins.out file.

var=''
for d2 in /etc/ckan/plugins/* ; do
    if [ "$var" != '' ] ; then
        var="$var $(cat $d2)"
    else
        var="$(cat $d2)"
    fi

    echo $var
done
if [ "$var" != '' ] ; then
    echo $var > /etc/ckan/plugins.out
fi
