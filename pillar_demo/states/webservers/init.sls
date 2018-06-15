# these should be set in pillar - but, if they aren't, we still want the state to function
{% set overrides = salt['pillar.get']('webservers:config', {}) %}
{% set servername = overrides.get('nginx:servername', 'awesome.local') %}
{% set docroot = overrides.get('nodejs:docroot', '/var/www/nodejs') %}
{% set nginx_port = overrides.get('nginx:port', '80') %}
{% set nodejs_port = overrides.get('nodejs:port', '8080') %}
{% set nodejs_bin = overrides.get('nodejs:bin', '/usr/bin/node') %}

nginx:
  pkg.installed

nodejs:
  pkg.installed

create-docroot:
  file.directory:
    - name: {{ docroot }}
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True

simple-webservice-jsfile:
  file.managed:
    - source: salt://webservers/files/simpleweb.js
    - name: {{ docroot }}/simpleweb.js
    - template: jinja
    - require:
      - create-docroot
      - pkg: nodejs

simple-webservice-systemd:
  file.managed:
    - source: salt://webservers/files/simpleweb.service
    - name: /etc/systemd/system/simpleweb.service
    - template: jinja
    - require:
      - pkg: nodejs
    - defaults:
      docroot: {{ docroot }}
      servername: {{ servername }}
      nodejs_port: {{ nodejs_port }}
      nodejs_bin: {{ nodejs_bin }}

start-simple-webservice:
  service.running:
    - name: simpleweb
    - enable: True
    - require:
      - simple-webservice-systemd
    - watch:
      - file: /etc/systemd/system/simpleweb.service
      - file: /var/www/nodejs/simpleweb.js

nginx-config-file-default:
  file.managed:
    - name: /etc/nginx/conf.d/default.conf
    - contents: '### THIS FILE IS MANAGED BY SALTSTACK - LOCAL CHANGES WILL BE DISCARDED!'

nginx-main-config-file:
  file.managed:
    - source: salt://webservers/files/nginx.conf
    - name: /etc/nginx/nginx.conf
    - mode: 640
    - require:
      - pkg: nginx

nginx-config-file:
  file.managed:
    - source: salt://webservers/files/simpleweb.conf
    - name: /etc/nginx/conf.d/simpleweb.conf
    - template: jinja
    - require:
      - pkg: nginx
    - defaults:
      docroot: {{ docroot }}
      servername: {{ servername }}
      nodejs_port: {{ nodejs_port }}
      nodejs_bin: {{ nodejs_bin }}
      nginx_port: {{ nginx_port }}


start-nginx:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - file: /etc/nginx/conf.d/simpleweb.conf
      - file: /etc/nginx/conf.d/default.conf
      - file: /etc/nginx/nginx.conf
