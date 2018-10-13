# get role & pxt
{% set dockerrole = salt['grains.get']('docker-role', []) %}
{% set PXT=salt['grains.get']('pxt') %}

# docker-ce MUST be installed for swarm to function correctly
# but, only install keepalived for master/manager nodes
{% if dockerrole == 'master' or dockerrole == 'manager' %}
include:
    - docker-ce
    - docker-ce-swarm-keepalived
{% else %}
include:
    - docker-ce
{% endif %}

# evaluate role and set up accordingly
{% if dockerrole == 'master' %}

# grab pillar data
{% set overrides = salt['pillar.get']('docker-swarm:lookup', {}) %}
{% set netif = salt['pillar.get']('docker-swarm:lookup:netif', {}) %}

# get the IP address of the master to build the init command
{% set ip = grains['ip4_interfaces'][netif][0] %}

# we must also manage in a config file so that the salt mine functions properly
/etc/salt/minion.d/swarm.conf:
  file.managed:
    - source: salt://docker-ce-swarm/files/swarm.conf
    - template: jinja
    - require:
      - pkg: install-docker-ce-packages

# TODO:
# first - does CHG manage in /etc/salt/minion? If so - make sure this line exists:
# include: minion.d/*
# the documentation says this is default but it lies
# second - write a reactor to force a mine update on the master host

# build commands for swarm (executed at end of state)
{% set swarm_init_cmd = 'docker swarm init --advertise-addr ' ~ ip %}
{% set swarm_unless_cmd = 'docker swarm join-token worker -q' %}

{% elif dockerrole == 'manager' %}


# get manager token from mine, as well as IP to join
{% set join_token = salt['mine.get']('G@pxt:'~PXT~ ' and G@roles:docker-swarm and G@docker-role:master', 'manager_token', expr_form='compound').items()[0][1] %}
{% set join_ip = salt['mine.get']('G@pxt:'~PXT~ ' and G@roles:docker-swarm and G@docker-role:master', 'manager_ip', expr_form='compound').items()[0][1][0] %}

# build commands
{% set swarm_init_cmd = 'docker swarm join --token ' ~ join_token ~ ' ' ~ join_ip  %}
{% set swarm_unless_cmd = 'docker swarm join-token manager -q' %}

{% elif dockerrole == 'worker' %}

# get worker token from mine, as well as IP to join
{% set join_token = salt['mine.get']('G@pxt:'~PXT~ ' and G@roles:docker-swarm and G@docker-role:master', 'worker_token', expr_form='compound').items()[0][1] %}
{% set join_ip = salt['mine.get']('G@pxt:'~PXT~ ' and G@roles:docker-swarm and G@docker-role:master', 'manager_ip', expr_form='compound').items()[0][1][0] %}

# build commands
{% set swarm_init_cmd = 'docker swarm join --token ' ~ join_token ~ ' ' ~ join_ip  %}
## this might be a hack. workers can't do anything with the swarm, by design. but if this file exists we're already a worker.
{% set swarm_unless_cmd = 'test -f /var/lib/docker/swarm/worker/tasks.db' %}

{% endif %}

# run the previously generated swarm commands
docker-swarm-cmd:
    cmd.run:
        - name: {{ swarm_init_cmd }}
        - unless: {{ swarm_unless_cmd }}
        - require:
            - pkg: install-docker-ce-packages

# if this is a master or manager node, drain connections so that the ONLY role is that of a manager
{% if dockerrole != 'worker' %}

docker-drain-cmd:
    cmd.run:
      - name: docker node update --availability drain {{ salt['grains.get']('id') }}
      - unless: docker node inspect {{ salt['grains.get']('id') }} | grep -q Availability.*drain
      - require:
        - pkg: install-docker-ce-packages

{% endif %}

# restart the salt minion if necessary
{% if dockerrole == 'master' %}

restart-salt-minion-for-swarm:
    service.running:
        - name: salt-minion
        - watch:
            - file: /etc/salt/minion.d/swarm.conf

{% endif %}
