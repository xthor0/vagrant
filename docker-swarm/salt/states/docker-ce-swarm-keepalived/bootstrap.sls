{% for server, addrs in salt['mine.get']('roles:haproxy', 'network.ip_addrs', expr_form='grain').items() %}

{% if loop.first %}
{% set conf_sls = 'keepalived.master' %}
{% else %}
{% set conf_sls = 'keepalived.backup' %}
{% endif %}

{{server}}.bootstrap.vip:
  salt.state:
    - sls: {{conf_sls}}
    - tgt: {{server}}


{% endfor %}
