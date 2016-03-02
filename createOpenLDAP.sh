#!/bin/bash
BASEDIR=$(readlink -f $(dirname $0))
set -e
LDAP_NAME=${LDAP_NAME:-openldap}
LDAP_VOLUME=${LDAP_VOLUME:-openldap-volume}
SLAPD_PASSWORD=${SLAPD_PASSWORD:-$1}
SLAPD_DOMAIN=${SLAPD_DOMAIN:-$2}
# TODO: There's a bug here. LDAP_IMAGE_NAME is not taken from config.default
LDAP_IMAGE_NAME=${LDAP_IMAGE_NAME:-ci/openldap}
CI_ADMIN_UID=${CI_ADMIN_UID:-$3}
CI_ADMIN_PWD=${CI_ADMIN_PWD:-$4}
CI_ADMIN_EMAIL=${CI_ADMIN_EMAIL:-$5}
PHPLDAPADMIN_NAME=${6:-phpldapadmin}
PHPLDAP_IMAGE_NAME=${7:-osixia/phpldapadmin}
PHPLDAP_LDAP_HOSTS=${PHPLDAP_LDAP_HOSTS:-openldap}

#Convert FQDN to LDAP base DN
SLAPD_TMP_DN=".${SLAPD_DOMAIN}"
while [ -n "${SLAPD_TMP_DN}" ]; do
SLAPD_DN=",dc=${SLAPD_TMP_DN##*.}${SLAPD_DN}"
SLAPD_TMP_DN="${SLAPD_TMP_DN%.*}"
done
SLAPD_DN="${SLAPD_DN#,}"

#Create OpenLDAP volume.
docker run \
--name ${LDAP_VOLUME} \
--entrypoint="echo" \
${LDAP_IMAGE_NAME} \
"Create OpenLDAP volume."

#Start openldap
docker run \
--name ${LDAP_NAME} \
-p 389:389 \
--volumes-from ${LDAP_VOLUME} \
-e SLAPD_PASSWORD=${SLAPD_PASSWORD} \
-e SLAPD_DOMAIN=${SLAPD_DOMAIN} \
-e USE_SSL=false \
-d ${LDAP_IMAGE_NAME}
#-v ${BASEDIR}/${BASE_LDIF}:/${BASE_LDIF}:ro \

#start Phpldap admin
docker run \
--name ${PHPLDAPADMIN_NAME} \
-p 7443:80 \
--link ${LDAP_NAME}:openldap \
-e PHPLDAPADMIN_LDAP_HOSTS=${PHPLDAP_LDAP_HOSTS} \
-e PHPLDAPADMIN_HTTPS=false \
-d ${PHPLDAP_IMAGE_NAME}
