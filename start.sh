#!/bin/bash

# Redirect all output of this script to log file
exec > >(tee "/var/log/ldap.log") 2>&1

FIRST_RUN=first_run.sh

if [[ -x /$FIRST_RUN ]]; then
    echo "Running first time setup..."
    /$FIRST_RUN &
fi

# Start slapd
exec slapd -d 32768 -u openldap -g openldap 
