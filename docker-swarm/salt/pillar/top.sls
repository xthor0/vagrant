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
    

    
