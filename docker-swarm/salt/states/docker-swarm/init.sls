# docker-ce MUST be installed for swarm to function correctly
# docker-ce MUST be installed for swarm to function correctly
include:
    - docker-ce

# do we have to restart the salt minion after placing this file? I'd assume so...
# get pillar data
{% set overrides = salt['pillar.get']('docker-swarm:lookup', {}) %}
{% set master = overrides.get('master', {}) %}
{% set netif = salt['pillar.get']('docker-swarm:lookup:netif', {}) %}
{% set ip = salt['cmd.shell']('ip a | grep -A2 ' ~ netif ~ ' | grep inet | cut -d \  -f 6 | cut -d / -f 1') %}

# if we are the master we build a command to join
# otherwise we just init
{% if master == 'self' %}

# we must also manage in a config file so that the salt mine functions properly:
/etc/salt/minion.d/swarm.conf:
  file.managed:
    - source: salt://docker-swarm/files/swarm.conf
    - template: jinja
    - require:
      - pkg: install-docker-ce-packages

{% set swarm_init_cmd = 'docker swarm init --advertise-addr ' ~ ip %}
{% set swarm_unless_cmd = 'docker swarm join-token worker -q' %}

{% else %}

# we get this from the mine
{% set join_token = salt['mine.get'](master, 'worker_token', expr_form='compound').items()[0][1] %}
{% set join_ip = salt['mine.get'](master, 'manager_ip', expr_form='compound').items()[0][1][0] %}
{% set swarm_init_cmd = 'docker swarm join --token ' ~ join_token ~ ' ' ~ join_ip  %}
## this might be a hack. workers can't do anything with the swarm, by design. but if this file exists we're already a worker.
{% set swarm_unless_cmd = 'test -f /var/lib/docker/swarm/worker/tasks.db' %}

{% endif %}

# todo: salt-mine to get the master token, I guess?
docker-join-swarm:
    cmd.run:
        - name: {{ swarm_init_cmd }}
        - unless: {{ swarm_unless_cmd }}
    require:
        - pkg: docker-ce

