How to use
=========================
1. Install VirtualBox and Vagrant
2. Install the [Vagrant Host Manager](https://github.com/devopsgroup-io/vagrant-hostmanager) plugin
3. run `vagrant up salt-master`
4. run `vagrant ssh salt-master` - make sure that the Salt master is running
5. In another shell, run `vagrant up centos7`
6. Ensure that, from your shell on the `salt-master` node, that a minion named `centos7` registers and you can communicate with it using Salt (e.g., `salt centos7 test.ping`)
7. You can bring up several flavors of OS minions with this Vagrantfile:
   1. Debian 9 `stretch`
   2. Debian 10 `buster`
   3. Centos 7 and 8
   4. Ubuntu `bionic`

## TODO

I can bring up as many CentOS 7 boxes as I want at a time, and it works.

Maybe I need to define a variable for each OS type. If passed, I'd spin up as many as specified... *shrug*



I see a problem with this scenario.

Let's say I spin up my env like this:

`cent7count=5 vagrant up`

I'll get 5 minions and a salt master. Hosts file will be updated, as expected.

Then, I want to add 2 Bionic boxes:

`bioniccount=2 vagrant up`

I'll get this error:

~~~
The machine with the name centos7-n1 was not found configured for this Vagrant environment.
~~~

I really don't want to make it spin up one of each OS type... that would suck.

Maybe I'll just have to specify a single OS type, and EVERYTHING will be built on that OS type. I can't change OS types on the fly without `vagrant destroy`, but it's better than a kick in the balls, right?