#!/bin/bash

# bash script to deploy a Salt master 

# Disable IPv6
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
/sbin/sysctl -p

# install new hosts file so all minions are pingable
cat /vagrant/etc/hosts > /etc/hosts

# I'm not sure why Patrick disables fastestmirror?
#sed -i 's/enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf

# install epel and then some programs I like to have
yum -y install epel-release
yum -y install wget screen rsync vim-enhanced bind-utils net-tools bash-completion bash-completion-extras

# Install Salt repo
yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm

# Expire YUM cache
yum clean expire-cache

# Install Salt
yum install -y salt salt-master salt-minion pyOpenSSL salt-api

# install salt config files for master
cat /vagrant/etc/master > /etc/salt/master

# Set local hostname
hostnamectl set-hostname master.localdev

# configure minion
cat /vagrant/etc/minion > /etc/salt/minion

# start minion
systemctl enable salt-minion
systemctl start salt-minion

# generate SSL cert for API
salt-call --local tls.create_self_signed_cert

# set the vagrant user's password so it can use the Salt API
echo r0ck0n | passwd --stdin vagrant

# start salt-api
systemctl enable salt-api
systemctl start salt-api

# Set Salt Master to start at reboot
systemctl enable salt-master.service

# Start Salt Minion service
systemctl start salt-master.service
