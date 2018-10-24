#!/bin/bash

# Disable IPv6
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
/sbin/sysctl -p

# install epel and some packages I like
yum -y install epel-release
yum -y install wget screen rsync vim-enhanced bind-utils net-tools bash-completion bash-completion-extras

# Set local hostname
hostnamectl set-hostname $1

# set the port for the node application
case "$1" in
    webapp1)
        NODEPORT=8081
        ;;
    webapp2)
        NODEPORT=8082
        ;;
    webapp3)
        # if you're looking at this to solve the puzzle, you're smart.
        # but you're also cheating because I told you not to do that.
        NODEPORT=8084
        ;;
esac

# configure the server accordingly
case "$1" in
    proxy)
        yum -y install nginx && systemctl enable nginx
        rm -f /etc/nginx/nginx.conf 
        ln -s /srv/config/nginx.conf /etc/nginx/nginx.conf
        systemctl start nginx
        ;;
    webapp*)
        yum -y install nodejs
        cat /srv/config/simpleweb.service | tee /etc/systemd/system/simpleweb.service >& /dev/null
        sed -i "s/%%port%%/${NODEPORT}/g" /etc/systemd/system/simpleweb.service
        sed -i "s/%%hostname%%/${1}/g" /etc/systemd/system/simpleweb.service
        systemctl daemon-reload
        systemctl enable simpleweb && systemctl start simpleweb
        ;;
esac