#!/bin/bash

curl -L https://bootstrap.saltstack.com -o /tmp/install_salt.sh && chmod u+x /tmp/install_salt.sh && /tmp/install_salt.sh -P && rm /tmp/install_salt.sh
if [ $? -ne 0 ]; then
  echo "Error: Minion did not deploy correctly!"
  exit 255
fi

# key should be auto-accepted on master at this point!
