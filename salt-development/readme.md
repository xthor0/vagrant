# Salt Development using Vagrant and Virtualbox
==================
I've probably overdone this. I have a habit of doing that, thinking that I need to refine a demo to the point of perfection. Oh well, maybe this'll be useful to someone. :)

## Requirements
What you'll need for this code to be useful:
- Git
- A computer with virtualization capabilities. MacOS or Linux would be my recommendation, but I helped a friend use this on Windows, and it worked surprisingly well. Just make sure you're in an elevated command prompt when you run the example vagrant commands. Any computer with 16GB RAM should be sufficient, I'm running this on a 2016 MacBook Pro with a quad-core i7 and have had as many as 9 VMs running. MacOS does a surprisingly good job with memory compression.
- Virtualbox - https://www.virtualbox.org/ - I'm using 5.2
- Vagrant - https://www.vagrantup.com/

I also recommend getting vagrant's bash completion module so you can tab-complete. On my Mac it was pretty easy to install (I already had bash-completion from homebrew installed:

~~~
curl -L https://raw.githubusercontent.com/hashicorp/vagrant/master/contrib/bash/completion.sh | tee $(brew --prefix)/etc/bash_completion.d/vagrant
~~~

## A few notes about my setup
Right now, this vagrant environment is configured to help me build a Docker CE swarm on CentOS 7. There's absolutely no reason it won't work with other salt states, though.

I know that Vagrant has some pre-build Salt masters, but this was so easy to set up I didn't really see the point. I'm the type of person that likes understanding what's going on under the hood, so...

This Vagrantfile will build a Salt master and up to 5 minions (but is already plumbed to go to 9 if your host can support the resource requirements). The Salt master is configured to automatically accept keys, and you can see the code that accomplishes this in the reactor config. I configured a private network on 192.168.221.0/24, but that can be easily adjusted if it conflicts with your network configuration.

# Getting started
## Checking out the necessary git repositories
First, you'll want to check out my entire Vagrant repository. I put everything in $HOME/git.
~~~
git clone https://github.com/xthor0/vagrant.git
~~~
Now, hopefully your existing Salt workflow uses GitFS. If it doesn't... well, you should be. Setting up your salt master to use GitFS is definitely outside the scope of this documentation, but it makes Salt development a LOT easier. Branching strategies with pull requests has really changed the way I develop states. I make a feature branch off of the dev branch of my Salt repository, do all of my local development in that feature branch, and test the hell out of it using this Vagrant setup. Then, I commit the work I've done, do a PR, and it gets pulled into the dev branch (and through a similar process eventually lands in production).

So, for my personal development workflow, I check out the Git repository that holds all my states, and the Vagrant setup points to that state tree for local development. For example, here's how I'd do that using my personal Github repo for Salt:
~~~
git clone https://github.com/xthor0/salt-top.git
cd salt-top
git branch -b fb_saltdev
< after editing a bunch of shit... >
git push --set-upstream origin fb_saltdev
git checkout dev
git merge fb_saltdev
~~~

So for the purpose of this writeup, we're going to assume your username is 'awesomedude' and you've checked out code to /Users/awesomedude/git/vagrant and /Users/awesomedude/git/salt-top - and that you've created your feature branch for development.

## Setting up your Vagrant master
Next, we're going to edit the Vagrantfile to match your environment, and spin up the master.

Pop into the Vagrant git repository you just checked out:

~~~
cd ~/git/vagrant/salt-development
~~~

Edit the Vagrantfile and change this line to match your setup (if necessary):
~~~
master.vm.synced_folder "~/git/salt/salt-top/", "/srv/salt/states/"
~~~

You'll notice there are a few directories already present in this Git repository:

- etc: contains a master, minion, and hosts file that gets pushed to every vagrant VM in this project
- salt-root: contains a bunch of configs necessary for this master to function correctly

The salt-root folder contains both the pillar data and the top.sls for highstate - that way you can independently apply states and pillar data, but still use the local repository. It's been pointed out to me that if you're using GitFS for all of this, you could simply tie into that and have your master config pull from the same git repository. This is true, but it comes at a cost. Your workflow would look like this:

Write/Change Code -> git commit && git push -> force Salt master to update GitFS -> test

With a local setup (as configured), your workflow looks like this:

Write/Change Code -> state.apply/state.highstate

Much simpler. :)

## Starting up the master
Once the Vagrantfile has been modified to match your configuration, spinning up the master is very straightforward:
~~~
vagrant up master
~~~

The first run will download a CentOS 7 image, so be patient.

Once you're back at a command prompt, check the output and make sure there were no errors. Otherwise, you can now log into your new master:
~~~
vagrant ssh master
~~~

## Start up minions
With no modifications, the Vagrantfile will build 5 minions. You can easily change this by modifying this line:
~~~
(1..5).each do |i|
  config.vm.define "minion#{i}" do |node|
  ... <snip> ...
~~~
For example, if you only want 2 minions:
~~~
(1..2).each do |i|
  config.vm.define "minion#{i}" do |node|
  ... <snip> ...
~~~
Just run this command to start up your minions:
~~~
vagrant up
~~~
The master will be skipped (since it's already up), and minions 1-5 will spin up. This'll take some time.

Once the vagrant process is complete, in your ssh session to the master, run this command as root and you'll see that all minions have registered with the master:
~~~
salt \* test.ping
~~~

## Pillar data
With no modifications, you should see pillar data for Docker CE:
~~~
salt 'minion*' pillar.items
~~~
You should see output like this:
~~~
minion1.localdev:
    ----------
    docker-swarm:
        ----------
        lookup:
            ----------
            netif:
                enp0s8
            routerid:
                58
            vip:
                192.168.221.15
            vrrp_pass:
                50Tg00m1HfqXGqHFXuY9cVFOY
            vrrp_prio:
                100
... <snip> ...
~~~

Yeah, that's really a vrrp password for keepalived. Don't worry, I've long since burned down the Vagrant environment so it's not useful anymore. :)

You can modify either 
~~~
/srv/salt/pillar/top.sls
~~~
(directly on the master), or in 
~~~
/Users/awesomedude/git/vagrant/salt-development/salt-root/pillar/top.sls
~~~
(on the host you're developing on). Either one is persistent, and will survive when the environment is destroyed.

## Highstate
Similar to the pillar data, you can find this in either
~~~
/srv/salt/top.sls
~~~
(on the master), or in
~~~
/Users/awesomedude/git/vagrant/salt-deveopment/salt-root/top.sls
~~~

## Cleaning up your mess
If you're not going to develop for a while and need to reclaim some resources, you can pause the VMs:
~~~
vagrant suspend
~~~
You can also remove the entire setup completely. No worries, it's not like you can't easily spin it back up!
~~~
vagrant destroy
~~~
For every running vagrant VM, you'll be asked to confirm.

## What's next?
If you have your own Salt development work to do, feel free to stop reading here. Otherwise, the rest of this documentation will help you build a Docker CE swarm.

## Docker CE Swarm
I'm not against using Salt formulas to make my life easier. But, surprisingly, I couldn't find a formula that installed Docker Community Edition on CentOS 7. They're either using some weird Git version, or the old version of Git. So... I wrote my own.

There's a fair amount of documentation here:

https://github.com/xthor0/salt-top/tree/dev/docker-ce-swarm

Just a disclaimer, though, this state was written assuming your Salt configuration is the same as ours, where we use grain data to target both highstate and pillar data. If you're not, adjust accordingly.

## Docker CE Quickstart
Here's a quick and dirty guide to making your fresh, new Vagrant environment into a Docker CE swarm. This assumes you followed all the instructions above and have a master and 5 minions running.

Log into the Salt master and run the following as root:
~~~
salt minion\* grains.append roles docker-ce-swarm
salt minion\* grains.setval pxt awesome
salt minion\* grains.setval env dev
salt minion1.localdev grains.append roles swarm-master
salt minion2.localdev grains.append roles swarm-manager
salt minion[3-5].localdev grains.append roles swarm-worker
~~~

Highstate the master:
~~~
salt minion1.localdev state.highstate
~~~

Make sure the mine works:
~~~
salt minion2.localdev mine.get 'minion1.localdev' manager_token
~~~
You'll see output like this:
~~~
minion2.localdev:
    ----------
    minion1.localdev:
        SWMTKN-1-303jiywr0zp6bas0eoxrvhtjm8uilc8zxftxe6zattjui39c1u-a4f6mnl1gyg67jdd7upcj6y2s
~~~

Finally, bring the remaining nodes up:
~~~
salt minion\* state.highstate
~~~

Confirm it's all working as expected:
~~~
salt minion1.localdev cmd.run 'docker node ls'
~~~
If you don't see all 5 nodes, check the output of highstate.

Also, you should have a single service running called Traefik:
~~~
salt minion1.localdev cmd.run 'docker service ls'
~~~

## Traefik
This state builds in Traefik, which is a really killer load balancer for Docker. I think it illustrates the power of Docker.

We manage a lot of reverse proxies. It's better than the Netscaler, because that is completely manual unless things have changed. We plumb in URIs via pillar data so that /something routes to the appropriate TCP port on the back-end. But, I thought, there HAS to be something better that can self-register with a docker-aware proxy. I found Traefik, and combined it with KeepaliveD (to ensure there was a static IP for ingress into the Docker swarm).

Visit http://192.168.221.15:8080 - that's the management interface for Traefik. Right now, you'll have 0 frontends and 0 backends.

But, run this command:
~~~
salt minion1.localdev cmd.run 'docker service create -q --name hello-world --network traefik-net --label traefik.port=8080 --label traefik.docker.network=traefik-net --label traefik.frontend.rule=PathPrefixStrip:/helloworld xthor/helloworld'
~~~
That will download a really, really simple NodeJS app from my Docker hub. All it does is tell you the container you're on. Once you get a service ID back from Salt, the service has been created. 

Once it spins up, go back to the Traefik page. Notice that a new service has registered.

You can see that the NodeJS app is responding at /helloworld:
~~~
curl http://192.168.221.15/helloworld
Node.js running on 8080 on container abfc6e0f80b0
~~~

Change the number of replicas:
~~~
salt minion1.localdev cmd.run 'docker service update hello-world --replicas 4 -q -d'
~~~
The command will exit quickly, but if you refresh the Traefik management page, check out what happens.

Also check out how the container ID changes on the curl command, indicating load balancing.