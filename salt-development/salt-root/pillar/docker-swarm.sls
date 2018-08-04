docker-swarm:
  lookup:
    netif: enp0s8
    routerid: 58
    {% set roles = salt['grains.get']('roles', []) %}
    {% if "swarm-master" in roles %}
    vrrp_prio: 100
    {% elif "swarm-manager" in roles %}
    vrrp_prio: 99
    {% endif %}
    vrrp_pass: 50Tg00m1HfqXGqHFXuY9cVFOY
    vip: 192.168.221.15
