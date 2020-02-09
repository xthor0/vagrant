#!/bin/bash

# bash script to deploy a Salt master 

# Disable IPv6
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
/sbin/sysctl -p

# install epel and then some programs I like to have
yum -y install epel-release
yum -y install wget screen rsync vim-enhanced bind-utils net-tools bash-completion bash-completion-extras

curl -L https://bootstrap.saltstack.com -o /tmp/install_salt.sh && chmod u+x /tmp/install_salt.sh && /tmp/install_salt.sh -x python3 -P -M && rm /tmp/install_salt.sh
if [ $? -ne 0 ]; then
  echo "Error installing Salt Master. Exiting."
  exit 255
else
  cat /vagrant/etc/master > /etc/salt/master && systemctl restart salt-master
  if [ $? -eq 0 ]; then
    echo "Salt master ready to rock and roll."
  else
    echo "Error configuring salt master."
    exit 255
  fi
fi
