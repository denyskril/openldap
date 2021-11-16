FROM ubuntu:focal

MAINTAINER kril.denis@gmail.com

ENV DEBIAN_FRONTEND=noninteractive

RUN echo 'slapd/root_password password password' | debconf-set-selections && \
	echo 'slapd/root_password_again password password' | debconf-set-selections && \
	apt update && apt install --no-install-recommends -y \
	ca-certificates \
	curl \
	gettext \
	ldap-utils \
	libsasl2-modules \
	libsasl2-modules-db \
	libsasl2-modules-gssapi-mit \
	libsasl2-modules-ldap \
	libsasl2-modules-otp \
	libsasl2-modules-sql \
	openssl \
	slapd \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN dpkg-reconfigure -f noninteractive slapd

#RUN echo "moduleload rwm\noverlay rwm\nrwm-map attribute uid sAMAccountName\nrwm-map objectClass posixGroup group\nrwm-map objectClass posixAccount person\nrwm-map objectClass memberUid member" >> /etc/ldap/ldap.conf

ADD run.sh /run.sh
RUN chmod a+x /run.sh

ADD slapd.conf /etc/ldap/slapd.conf
ADD ldap.conf.template /tmp/ldap.conf.template
ADD bootstrap.ldif.template /tmp/bootstrap.ldif.template
RUN rm -Rf /etc/ldap/slapd.d && mkdir /etc/ldap/slapd.d

#EXPOSE 389 636

CMD ["/run.sh"]
#CMD ["/usr/sbin/slapd", "-g", "openldap", "-u", "openldap", "-h", "ldap:///:389,ldaps:///:636,ldapi:///", "-F", "/etc/ldap/slapd.d", "-d256"]
