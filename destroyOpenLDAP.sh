#!/bin/bash

LDAP_NAME=${LDAP_NAME:-openldap}
LDAP_VOLUME=${LDAP_VOLUME:-openldap-volume}
PHPLDAPADMIN_NAME=${PHPLDAPADMIN_NAME:-phpldapadmin}

echo "Removing ${LDAP_NAME}..."
docker stop ${LDAP_NAME} &> /dev/null
docker rm -v ${LDAP_NAME} &> /dev/null

echo "Removing ${LDAP_VOLUME}..."
docker rm -v ${LDAP_VOLUME} &> /dev/null

echo "Removing ${PHPLDAPADMIN_NAME}..."
docker stop ${PHPLDAPADMIN_NAME} &> /dev/null
docker rm -v ${PHPLDAPADMIN_NAME} &> /dev/null

