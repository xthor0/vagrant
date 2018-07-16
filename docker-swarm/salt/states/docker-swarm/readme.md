Instructions for using docker-swarm salt state files
====================================================

## Set up your pillar data
Setting up your master node should be fairly easy. Here's what my pillar top.sls file looked like for development:

base:
    'G@roles:docker-swarm and G@roles:docker-swarm-master':
        - match: compound
        - docker-swarm-master
    
    'G@roles:docker-swarm and G@roles:docker-swarm-manager':
        - match: compound
        - docker-swarm-manager

    'G@roles:docker-swarm and G@roles:docker-swarm-worker':
        - match: compound
        - docker-swarm-worker
    

TODO: I need to get the salt.mine working so that the manager and workers can pull the docker swarm token.

this is how salt-mine works, pretty easy:

/etc/salt/minion.d/swarm.conf:
  file.managed:
    - source: salt://docker-swarm/files/swarm.conf
    - require:
      - pkg: docker-ce

only thing is, it needs to be set up BEFORE we try to join the swarm - the minion must be restarted... this is gonna be tricky.

this needs a lot of work, but I keep forgetting to do this:

salt docker-swarm4 grains.append roles docker-swarm-worker

before this:

salt docker-swarm4 state.highstate

it's a really obtuse error I get when I forget to do this:

[root@master ~]# salt docker-swarm4 state.highstate
docker-swarm4:
    Data failed to compile:
----------
    Rendering SLS 'base:docker-swarm' failed: Jinja variable list object has no element 0
ERROR: Minions returned with non-zero exit code

this needs to make it into the documentation, somehow - setting up pillars and grains appropriately is muy importante.