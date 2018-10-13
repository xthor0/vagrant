How to use this demo
=========================
1. clone the repository (obviously)
2. cd salt-dev
3. edit Vagrantfile and change the 'minions' variable to match how many you want. Make sure you change the IP address, as well.
4. run `vagrant up master`
5. run `vagrant ssh master`
6. Run `sudo salt \* test.ping` and make sure `master.localdev` is listed as a minion
7. Exit the shell
8. Run `vagrant up minion1`
9. Run `vagrant ssh master` and see if the Salt `test.ping` command shows your new minion
10. Repeat if you want more than one minion
