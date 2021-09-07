icinga2:
    database:
        username: icinga
        password: daintily-reactor-lapel-shaded-preflight-ensure
        icingaweb2_db_name: icingaweb2
        icinga2_db_name: icinga2
    pushover:
        apptoken: a8s3912jnc6penim7goximyeakqshv
        usertoken: uiLUuynXsvF7UCQATr3j6j7pG7dGoh
    apiusers:
        icingaweb2:
            password: Lutf3ahos9bQZUEGExLBNu1QM
    icingaweb2:
        username: admin
        hashed_password: $2y$10$vmjq4kEVJbBD76dRShYsUe16b4kq0CgOIqH54Wck78N.O6v9r3FzC
    hosts:
        bullseye-2:
            ip: 192.168.56.192
            template: linux-host
        bionic-1:
            ip: 192.168.56.234
            template: linux-host
        centos8-1:
            ip: 192.168.56.160
            template: linux-host
