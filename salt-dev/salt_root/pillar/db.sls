mariadb:
    config:
        file: /etc/my.cnf
        sections:
            mysqld:
                bind-address: 127.0.0.1
                port: 3306
                socket: /var/lib/mysql/mysql.sock
                datadir: /var/lib/mysql
                symbolic-links: 0
    master_user:
        username: root
        password: unselect-poise-entryway-outclass-scavenger-smoking
    users:
        icinga:
            password: daintily-reactor-lapel-shaded-preflight-ensure
            host: localhost
    databases:
        icinga:
            user: icinga
        icingaweb2:
            user: icinga