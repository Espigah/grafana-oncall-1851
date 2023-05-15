FROM grafana/oncall:v1.2.16 as base
RUN apt update && apt install -y nano

##################################
## Grafana Engine API
##################################
FROM base as engine

ENV APP_USER                            espigah
ENV APP_GROUP                           espigah
ENV APP_HOME                            /etc/app

COPY ./uwsgi.ini ${APP_HOME}/uwsgi.ini

RUN useradd -ms /bin/bash ${APP_USER}

RUN chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME}
RUN chown -R ${APP_USER}:${APP_GROUP} /usr/local/bin/uwsgi
USER ${APP_USER}


CMD ["uwsgi", "--ini", "uwsgi.ini"]

##################################
## Celery
##################################
FROM base as celery

ENV APP_USER                            espigah
ENV APP_GROUP                           espigah
ENV APP_HOME                            /etc/app


RUN useradd -ms /bin/bash ${APP_USER}

RUN chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME}
USER ${APP_USER}

CMD ["sh", "-c", "./celery_with_exporter.sh"]

##################################
## Migrate database
##################################
FROM base as migrate 
ENV APP_HOME                            /etc/app


COPY ./manage.py ${APP_HOME}/manage.py

CMD ["python", "manage.py", "migrate", "--noinput"]

