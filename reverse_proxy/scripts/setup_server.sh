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
        cat /srv/config/nginx.conf | tee /etc/nginx/nginx.conf >& /dev/null
        mkdir -p /srv/www && chcon -t httpd_sys_content_t /srv/www
        cat /srv/config/index.html | tee /srv/www/index.html >& /dev/null
        systemctl start nginx
        ;;
    webapp*)
        yum -y install nodejs
        mkdir -p /srv/www 
        cp /srv/scripts/simpleweb.js /srv/www/
        cat /srv/config/simpleweb.service | tee /etc/systemd/system/simpleweb.service >& /dev/null
        sed -i "s/%%port%%/${NODEPORT}/g" /etc/systemd/system/simpleweb.service
        sed -i "s/%%hostname%%/${HOSTNAME}/g" /etc/systemd/system/simpleweb.service
        systemctl daemon-reload
        systemctl enable simpleweb && systemctl start simpleweb
        ;;
esac