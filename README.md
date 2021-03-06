docker-graylog
==============

Docker image running graylog2

To spawn a container one might use:
```
# To get all the /dev/* devices needed for sshd and alike:
export DEV_MOUNTS="-v /dev/urandom:/dev/urandom -v /dev/random:/dev/random"
export DEV_MOUNTS="${DEV_MOUNTS} -v /dev/null:/dev/null -v /dev/zero:/dev/zero"
# To let syslog-ng access /proc/kmsg
OPTS="--privileged"
# If an qnib/elk instance is running, syslog would be forwarded
OPTS="${OPTS} --link elk:elk"
# system-metrics are forwarded to carbon, if available
OPTS="${OPTS} --link carbon:carbon"
# Interactive
docker run -ti --rm ${OPTS} ${DEV_MOUNTS} -h graylog2 --name graylog2 -p 9000:9000 -p 12900:12900 qnib/graylog /bin/bash
bash-4.2# /usr/local/bin/supervisor_daemonize.sh
# supervisorctl status
diamond                          RUNNING   pid 17, uptime 0:00:04
elasticsearch                    RUNNING   pid 15, uptime 0:00:04
graylog2-server                  STARTING
graylog2-web-interface           STARTING
mongodb                          RUNNING   pid 14, uptime 0:00:04
setup                            RUNNING   pid 13, uptime 0:00:04
sshd                             RUNNING   pid 16, uptime 0:00:04
syslog-ng                        RUNNING   pid 19, uptime 0:00:04
bash-4.2#
# background
docker run -d ${OPTS} ${DEV_MOUNTS} -h graylog2 --name graylog2 -p 9000:9000 -p 12900:12900 qnib/graylog
```

Afterwards GRAYLOG2 can be accessed on port 9000 http://<docker_host>:9000 (admin/admin).

Since I am not quite sure how to delay the start of supervisord programms graylog2-server and -web-interface will fail once or twice until the other components are up'n'running,
but who cares... :)
