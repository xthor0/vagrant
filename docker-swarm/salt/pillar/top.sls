base:
    'G@roles:docker-swarm and G@docker-role:master and G@pxt:ben':
        - match: compound
        - docker-swarm-master  
    'G@roles:docker-swarm and G@docker-role:manager and G@pxt:ben':
        - match: compound
        - docker-swarm-manager
