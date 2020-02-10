# I like to install these packages on all my servers
base-packages:
  pkg.installed:
    - pkgs:
      - bash-completion
      - screen
{% if grains.get('os_family', '') == 'RedHat' %}
      - vim-enhanced
      - bind-utils
{% elif grains.get('os_family', '') == 'Debian' %}
      - vim
      - bind9utils
{% endif %}

# add these aliases to /home/vagrant/.bashrc
/home/vagrant/.bashrc:
  file.append:
    - text:
      - alias salt="sudo salt"
      - alias salt-call="sudo salt-call"
      - alias salt-key="sudo salt-key"
      - alias systemctl="sudo systemctl"

