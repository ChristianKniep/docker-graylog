###### Graylog2 images
# A docker image that includes
# - graylog2-server
# - graylog2-web-interface
# - (graylog2-radio)
FROM qnib/terminal
MAINTAINER "Christian Kniep <christian@qnib.org>"

# mongodb
RUN yum install -y mongodb-server
ADD etc/supervisord.d/mongodb.ini /etc/supervisord.d/mongodb.ini

## download stuff first to be able to cache this step for good
WORKDIR /opt/
RUN curl -L -o graylog2-server-0.20.6.tgz https://github.com/Graylog2/graylog2-server/releases/download/0.20.6/graylog2-server-0.20.6.tgz
RUN tar xf graylog2-server-0.20.6.tgz
RUN curl -L -o graylog2-web-interface-0.20.6.tgz https://github.com/Graylog2/graylog2-web-interface/releases/download/0.20.6/graylog2-web-interface-0.20.6.tgz
RUN tar xf graylog2-web-interface-0.20.6.tgz
RUN rm /opt/graylog*.tgz
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
RUN ln -sf /opt/graylog2-server-0.20.6 /opt/graylog2-server
RUN cp /opt/graylog2-server/graylog2.conf.example /etc/graylog2.conf
RUN sed -i -e "s/password_secret =$/password_secret = $(pwgen -s 96)/" /etc/graylog2.conf
RUN sed -i -e "s/root_password_sha2 =$/root_password_sha2 = $(echo -n admin | shasum -a 256|awk '{print $1}')/" /etc/graylog2.conf
ADD etc/supervisord.d/graylog2-server.ini /etc/supervisord.d/graylog2-server.ini

# web-interface
RUN ln -s /opt/graylog2-web-interface-0.20.6 graylog2-web-interface
RUN sed -i -e "s/application.secret=\"\"/application.secret=\"$(pwgen -s 96)\"/" /opt/graylog2-web-interface/conf/graylog2-web-interface.conf
RUN sed -i -e 's#graylog2-server.uris=.*"#graylog2-server.uris="http://127.0.0.1:12900/"#' /opt/graylog2-web-interface/conf/graylog2-web-interface.conf
ADD etc/supervisord.d/graylog2-web-interface.ini /etc/supervisord.d/graylog2-web-interface.ini

EXPOSE 9000
EXPOSE 12900

CMD /bin/supervisord -c /etc/supervisord.conf
