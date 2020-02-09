#!/bin/bash

# why isn't curl included in a cloud image by default? I have no idea, but we have to work around it
which curl >& /dev/null
if [ $? -eq 0 ]; then
  curl -L https://bootstrap.saltstack.com -o /tmp/install_salt.sh
else
  which wget >& /dev/null
  if [ $? -eq 0 ]; then
    wget https://bootstrap.saltstack.com -O /tmp/install_salt.sh
  else
    echo "Missing both wget and curl - exiting."
    exit 255
  fi
fi

chmod u+x /tmp/install_salt.sh && /tmp/install_salt.sh -x python3 -P && rm /tmp/install_salt.sh
if [ $? -ne 0 ]; then
  echo "Error: Minion did not deploy correctly!"
  exit 255
fi

# key should be auto-accepted on master at this point!
