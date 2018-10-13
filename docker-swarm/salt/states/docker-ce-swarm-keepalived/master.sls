keepalived.conf:
  file.managed:
    - name: /etc/keepalived/keepalived.conf
    - source: salt://keepalived/templates/keepalived.master.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644

keepalived.service:
  service.running:
    - name: keepalived
    - enable: True
    - reload: True
    - watch:
      - file: /etc/keepalived/keepalived.conf 
