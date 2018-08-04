docker_new_master:
  local.cmd.run:
    - tgt: {{ data['id'] }}
    - arg:
      - 'sleep 5 && systemctl restart salt-minion && salt-call mine.update'
