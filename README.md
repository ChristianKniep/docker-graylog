docker-graylog
==============

Docker image running graylog2

To spawn a container one might use:
```
docker run -t -i --rm=true -h graylog2 --name graylog2 --dns $(docker inspect -f '{{ .NetworkSettings.IPAddress }}' master) -p 9000:9000 -p 12900:12900 qnib/graylog 
```
The --dns option indicates where the etcd server is running which will be used to send the hostname:ip_addr information to.
TODO: Disable the setup of this, in case the container is not spawned in a QNIBTerminal environment.

Since I am not quite sure how to delay the start of supervisord programms graylog2-server and -web-interface will fail once or twice until the other components are up'n'running,
but who cares... :)
