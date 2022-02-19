FROM alpine:latest

# Configure Postgres
FROM postgres:11-alpine as dumper

COPY res/createdb.sql /docker-entrypoint-initdb.d/

RUN ["sed", "-i", "s/exec \"$@\"/echo \"skipping...\"/", "/usr/local/bin/docker-entrypoint.sh"]

ENV POSTGRES_USER=postgres
ENV PGDATA=/data
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_HOST_AUTH_METHOD=trust

RUN ["/usr/local/bin/docker-entrypoint.sh", "postgres"]

# final build stage
FROM postgres:11-alpine

COPY --from=dumper /data $PGDATA


# Set enviromment
ENV TOMCAT_VERSION_MAJOR 9
ENV TOMCAT_VERSION_FULL  9.0.8
ENV CATALINA_HOME /opt/tomcat

RUN apk --update add openjdk11-jre

# Install Tomcat
RUN apk add --update curl
RUN curl -LO https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION_MAJOR}/v${TOMCAT_VERSION_FULL}/bin/apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz
RUN tar -zxvf apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz
RUN mv apache-tomcat-${TOMCAT_VERSION_FULL} /opt/tomcat
RUN rm -rf /var/cache/apk/*

# Configure Tomcat
COPY res/tomcat-users.xml /opt/tomcat/conf/
COPY res/context.xml /opt/tomcat/webapps/manager/META-INF/
RUN sed -i 's/8080/9012/g' /opt/tomcat/conf/server.xml
RUN rm -rf /opt/tomcat/webapps/examples /opt/tomcat/webapps/docs
RUN mv /opt/tomcat/webapps/ROOT /opt/tomcat/webapps/tomcat
RUN mv /opt/tomcat/webapps/manager /opt/tomcat/webapps/ROOT

ADD build/libs/ /opt/tomcat/webapps/

CMD ["/bin/sh", "-c", "set -ex && apk --no-cache add sudo && sudo -u postgres chmod 0700 /var/lib/postgresql/data && sudo -u postgres pg_ctl start -D /var/lib/postgresql/data && ${CATALINA_HOME}/bin/catalina.sh run"]






