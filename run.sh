#!/usr/bin/env bash

LDAP_ROOT_PASSWORD=test

export LDAP_ROOT_PASSWORD=$(slappasswd -s ${LDAP_ROOT_PASSWORD})
echo ${LDAP_ROOT_PASSWORD}

export LDAP_BASE_DN=$(echo ${LDAP_DOMAIN} | awk -F '.' '{ for(i = 1; i <= NF; i++) { printf("dc=%s,", $i); }}' | sed 's/.$//')

echo "slapd slapd/no_configuration boolean false" | debconf-set-selections
echo "slapd slapd/domain string ${LDAP_DOMAIN}" | debconf-set-selections
echo "slapd shared/organization string '${LDAP_ORGANIZATION}'" | debconf-set-selections
echo "slapd slapd/password1 password ${LDAP_PASSWORD}" | debconf-set-selections
echo "slapd slapd/password2 password ${LDAP_PASSWORD}" | debconf-set-selections
echo "jslapd slapd/backend select HDB" | debconf-set-selections
echo "slapd slapd/purge_database boolean true" | debconf-set-selections
echo "slapd slapd/allow_ldap_v2 boolean true" | debconf-set-selections
echo "slapd slapd/move_old_database boolean true" | debconf-set-selections

dpkg-reconfigure -f noninteractive slapd

envsubst < /tmp/ldap.conf.template > /etc/ldap/ldap.conf
envsubst < /tmp/bootstrap.ldif.template > /tmp/bootstrap.ldif

#ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/bootstrap.ldif
ldapadd -H ldap://localhost:389 -D cn=admin,${LDAP_BASE_DN} -x -f /tmp/bootstrap.ldif -w test

#/usr/sbin/slapd -g openldap -u openldap -h ldap:///:389,ldaps:///:636,ldapi:/// -F /etc/ldap/slapd.d -d256
/usr/sbin/slapd -g openldap -u openldap -h "ldap:///:389 ldaps:///:636 ldapi:///" -F /etc/ldap/slapd.d -d256
