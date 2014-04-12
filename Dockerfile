###### Graylog2 images
# A docker image that includes
# - graylog2-server
# - graylog2-web-interface
# - (graylog2-radio)
FROM qnib/fd20
MAINTAINER "Christian Kniep <christian@qnib.org>"

# some stuff we need
RUN yum install -y wget openssh-server
RUN sshd-keygen

# Set (very simple) password for root
RUN echo "root:root"|chpasswd

## supervisord
RUN yum install -y supervisor 
RUN mkdir -p /var/log/supervisor
RUN sed -i -e 's/nodaemon=false/nodaemon=true/' /etc/supervisord.conf

# mongodb
RUN yum install -y mongodb-server
ADD etc/supervisord.d/mongodb.ini /etc/supervisord.d/mongodb.ini

## download stuff first to be able to cache this step for good
WORKDIR /opt/
RUN wget https://github.com/Graylog2/graylog2-server/releases/download/0.20.2-snapshot.2/graylog2-server-0.20.2-snapshot.2.tgz >/dev/null 2>&1
RUN wget https://github.com/Graylog2/graylog2-web-interface/releases/download/0.20.2-snapshot/graylog2-web-interface-0.20.2-snapshot.tgz >/dev/null 2>&1
# Java
RUN yum install -y java-1.7.0-openjdk

ADD etc/yum.repos.d/elasticsearch-0.90.repo /etc/yum.repos.d/elasticsearch-0.90.repo
RUN yum install -y elasticsearch
RUN sed -i -e '/# cluster.name:.*/a cluster.name: graylog2' /etc/elasticsearch/elasticsearch.yml
RUN sed -i -e "/# node.name:.*/a node.name: $(hostname)" /etc/elasticsearch/elasticsearch.yml
ADD etc/supervisord.d/elasticsearch.ini /etc/supervisord.d/elasticsearch.ini


#### Install graylog2
RUN yum install -y pwgen
# server
RUN yum install -y perl-Digest-SHA
RUN tar xf graylog2-server-0.20.2-snapshot.2.tgz
RUN ln -sf graylog2-server-0.20.2-snapshot /opt/graylog2-server
RUN cp /opt/graylog2-server/graylog2.conf.example /etc/graylog2.conf
RUN sed -i -e "s/password_secret =/password_secret = $(pwgen -s 96)/" /etc/graylog2.conf
ADD etc/supervisord.d/graylog2-server.ini /etc/supervisord.d/graylog2-server.ini

# web-interface
RUN tar xf graylog2-web-interface-0.20.2-snapshot.tgz
RUN ln -s graylog2-web-interface-0.20.2-snapshot graylog2-web-interface
RUN sed -i -e 's#graylog2-server.uris=#graylog2-server.uris="http://127.0.0.1:12900/"#' /opt/graylog2-web-interface/conf/graylog2-web-interface.conf
RUN sed -i -e "s/application.secret=\"\"/application.secret=\"$(pwgen -s 96)\"/" /opt/graylog2-web-interface/conf/graylog2-web-interface.conf



# tidy up a bit
#RUN rm /opt/graylog*.tgz

EXPOSE 9000
