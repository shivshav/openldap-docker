FROM openfrontier/openldap

MAINTAINER shiv <shiv@demo.com>

ENV CI_ADMIN_UID admin
ENV CI_ADMIN_PWD passwd
ENV CI_ADMIN_EMAIL admin@demo.com

COPY base.ldif.template first_run.sh start.sh /

CMD ["/start.sh"]
