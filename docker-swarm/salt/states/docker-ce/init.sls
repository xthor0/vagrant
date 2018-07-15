# install packages plus bash-completion files for Docker CE

# only works on CentOS 7 right now :)
{% if grains.get('os', '') == 'CentOS' and grains.get('osmajorrelease', '') == '7' %}

docker-ce-repo:
    pkgrepo.managed:
        - humanname: Docker CE Stable - $basearch
        - baseurl: https://download.docker.com/linux/centos/7/$basearch/stable
        - gpgcheck: 1
        - gpgkey: https://download.docker.com/linux/centos/gpg
        - failovermethod: priority

install-docker-ce-packages:
    pkg.installed:
        - pkgs:
            - docker-ce
            - bash-completion
            - bash-completion-extras
    require:
        - pkgrepo: docker-ce-repo

install-bash-completion-docker:
    file.managed:
        - source: https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker
        - source_hash: 1815000058cb44c4f87373a72d5abef328c95e1729a3f0be178371467fab110b
        - name: /etc/bash_completion.d/docker.sh
        - mode: 644
        - owner: root
        - group: root

{% endif %}
