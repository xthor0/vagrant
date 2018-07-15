# docker-ce MUST be installed for swarm to function correctly
include:
    - docker-ce

# are we a master node? we have 2 masters and (minimum) 3 workers in a cluster
# unless we find the pillar values we expect, we assume this minion is the first node in the cluster
{% if pillar.get('master_token', '') }