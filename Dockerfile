FROM openfrontier/openldap

MAINTAINER shiv <shiv@demo.com>

ENV CI_ADMIN_UID admin
ENV CI_ADMIN_PWD passwd

COPY base.ldif.template /base.ldif.template
COPY first_run.sh /first_run.sh
COPY start.sh /start.sh

RUN chmod +x ./start.sh ./first_run.sh

CMD ["/start.sh"]
