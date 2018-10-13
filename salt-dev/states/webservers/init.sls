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

ssl-cert-script:
  file.managed:
    - source: salt://webservers/files/gencert.sh
    - name: /usr/local/bin/gencert.sh
    - user: root
    - group: root
    - mode: 700
    - template: jinja
    - defaults:
      servername: {{ salt['grains.get']('id') }}

generate-ssl-cert:
  cmd.run:
    - name: /usr/local/bin/gencert.sh
    - require:
      - file: ssl-cert-script

create-docroot:
  file.directory:
    - name: {{ docroot }}
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True

# loop through all defined apps
{% set applist = salt['pillar.get']('apps', {}) %}
{% for app in applist -%}

{{ pillar['apps'][app]['shortname'] }}-script:
  file.managed:
    - source: salt://webservers/files/simpleweb.js
    - name: {{ pillar['apps'][app]['script'] }}
    - template: jinja
    - require:
      - create-docroot
      - pkg: nodejs
    - defaults:
      appname: {{ pillar['apps'][app]['shortname'] }}

{{ pillar['apps'][app]['shortname'] }}-systemd:
  file.managed:
    - source: salt://webservers/files/simpleweb.service
    - name: /etc/systemd/system/{{ pillar['apps'][app]['shortname'] }}.service
    - template: jinja
    - require:
      - pkg: nodejs
    - defaults:
      docroot: {{ docroot }}
      nodejs_port: {{ pillar['apps'][app]['port'] }}
      nodejs_bin: {{ nodejs_bin }}
      script: {{ pillar['apps'][app]['script'] }}
      appname: {{ pillar['apps'][app]['shortname'] }}

start-{{ pillar['apps'][app]['shortname'] }}-webservice:
  service.running:
    - name: {{ pillar['apps'][app]['shortname'] }}
    - enable: True
    - require:
      - {{ pillar['apps'][app]['shortname'] }}-systemd
    - watch:
      - file: /etc/systemd/system/{{ pillar['apps'][app]['shortname'] }}.service
      - file: {{ pillar['apps'][app]['script'] }}

# end loop on apps
{% endfor %}

nginx-config-build:
  file.managed:
    - source: salt://webservers/files/simpleweb.conf
    - name: /etc/nginx/conf.d/simpleweb.conf
    - template: jinja
    - require:
      - pkg: nginx
    - defaults:
      docroot: {{ docroot }}
      servername: {{ servername }}
      nodejs_bin: {{ nodejs_bin }}

nginx-config-build-2:
  file.managed:
    - source: salt://webservers/files/simpleweb.conf
    - name: /etc/nginx/conf.d/dingleberry.conf
    - template: jinja
    - require:
      - pkg: nginx
    - defaults:
      docroot: {{ docroot }}
      servername: {{ servername }}
      nodejs_bin: {{ nodejs_bin }}


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

start-nginx:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - file: /etc/nginx/conf.d/simpleweb.conf
      - file: /etc/nginx/conf.d/default.conf
      - file: /etc/nginx/nginx.conf
