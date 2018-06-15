# TODO: Map with context, see one of the states already written like jenkins...

nginx:
  pkg.installed

nodejs:
  pkg.installed

create-docroot:
  file.directory:
    - name: {{ salt['pillar.get']('nodejs:docroot') }}
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True

simple-webservice-jsfile:
  file.managed:
    - source: salt://webservers/files/simpleweb.js
    - name: {{ salt['pillar.get']('nodejs:docroot') }}/simpleweb.js
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

start-simple-webservice:
  service.running:
    - name: simpleweb
    - enable: True
    - require:
      - simple-webservice-systemd
    - watch:
      - file: /etc/systemd/system/simpleweb.service

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

start-nginx:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - file: /etc/nginx/conf.d/simpleweb.conf
      - file: /etc/nginx/conf.d/default.conf
      - file: /etc/nginx/nginx.conf
