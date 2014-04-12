#!/bin/bash

echo "### Fetch MASTER_IP"
MASTER_IP=$(cat /etc/resolv.conf |grep nameserver|head -n1|awk '{print $2}')
echo "MASTER_IP=${MASTER_IP}"
export no_proxy=${MASTER_IP}
echo "### Fetch MY_IP"
MY_IP=$(ip -o -4 addr|grep eth0|awk '{print $4}'|awk -F/ '{print $1}')
echo "MY_IP=${MY_IP}"
echo "### Send IP to etcd"
echo "# curl -s -XPUT http://${MASTER_IP}:4001/v2/keys/helix/$(hostname)/A -d value=${MY_IP}"
curl -s -XPUT "http://${MASTER_IP}:4001/v2/keys/helix/$(hostname)/A" -d value="${MY_IP}"

sed -i -e "s/graylog2-server.uris=\"\"/graylog2-server.uris=\"http:\/\/${MY_IP}:12900\"/" /opt/graylog2-web-interface/conf/graylog2-web-interface.conf
sed -i -e "s/^rest_listen_uri/###rest_listen_uri/" /etc/graylog2.conf
sed -i -e "/###rest_listen_uri.*/a rest_listen_uri = http:\/\/${MY_IP}:12900/" /etc/graylog2.conf
exit 0
