Instructions for using docker-swarm salt state files
====================================================

## The first docker host in your cluster will become the manager.
Really, you don't need anything in the pillar for the first host. It becomes a manager by default, but if you don't pay attention to the output from the Salt state, you'll miss the token that you need to put in the 