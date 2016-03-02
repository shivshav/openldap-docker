#!/bin/bash

BASE_LDIF=base.ldif
CI_ADMIN_EMAIL=${CI_ADMIN_UID}@${SLAPD_DOMAIN}

#Convert FQDN to LDAP base DN
SLAPD_TMP_DN=".${SLAPD_DOMAIN}"
while [ -n "${SLAPD_TMP_DN}" ]; do
SLAPD_DN=",dc=${SLAPD_TMP_DN##*.}${SLAPD_DN}"
SLAPD_TMP_DN="${SLAPD_TMP_DN%.*}"
done
SLAPD_DN="${SLAPD_DN#,}"

#Create base.ldif
sed -e "s/{SLAPD_DN}/${SLAPD_DN}/g" /${BASE_LDIF}.template > /${BASE_LDIF}
sed -i "s/{ADMIN_UID}/${CI_ADMIN_UID}/g" /${BASE_LDIF}
sed -i "s/{ADMIN_EMAIL}/${CI_ADMIN_EMAIL}/g" /${BASE_LDIF}

# Short waits to prevent errors
while [ ! -f /var/log/ldap.log ]; do
    sleep 1
done
echo "syslog found"

while [ -z "$(tail -n 4 /var/log/ldap.log | grep 'slapd starting')" ]; do
    echo "Waiting openldap ready."
    sleep 1
done

echo "slapd is ready."

#Import accounts
echo "Adding initial entries"
ldapadd -f /${BASE_LDIF} -x -D "cn=admin,${SLAPD_DN}" -w ${SLAPD_PASSWORD}

## Setup CI Admin user's password
echo "Setting up CI Admin's password"
ldappasswd -x -D "cn=admin,${SLAPD_DN}" -w ${SLAPD_PASSWORD} -s ${CI_ADMIN_PWD} \
"uid=${CI_ADMIN_UID},ou=accounts,${SLAPD_DN}"

## Test User Account
echo "Setting up testuser's password"
ldappasswd -x -D "cn=admin,${SLAPD_DN}" -w ${SLAPD_PASSWORD} -s testpass \
"uid=testuser,ou=accounts,${SLAPD_DN}"

# Add testuser to developers group for testing
echo "Adding users to initial groups"

echo "Adding CI Admin to admin group"
ldapmodify -x -D "cn=admin,dc=demo,dc=com" -w secret <<!123
dn: cn=admin,ou=groups,dc=demo,dc=com
changetype: modify
replace: memberUid
memberUid: admin
!123

echo "Adding testuser to developers group"
#echo "dn: cn=developers,ou=groups,dc=demo,dc=com
#changetype: modify 
#add: memberUid 
#memberUid: testuser
#" | ldapmodify -x -D "cn=admin,dc=demo,dc=com" -w secret
ldapmodify -x -D "cn=admin,dc=demo,dc=com" -w secret <<!123
dn: cn=developers,ou=groups,dc=demo,dc=com
changetype: modify
replace: memberUid
memberUid: testuser
!123

echo "Exiting first_run.sh..."
rm /first_run.sh
