webservers:
  config:
    nginx:
      servername: awesome.local
      port: 80
apps:
  helloworld:
    uri: /hello
    name: "Hello World"
    shortname: helloworld
    bin: /usr/bin/node
    script: /var/www/nodejs/helloworld.js
    docroot: /var/www/nodejs
    port: 8080
  whatsup:
    name: "What's Up"
    uri: /whatsup
    shortname: whatsup
    bin: /usr/bin/node
    script: /var/www/nodejs/whatsup.js
    docroot: /var/www/nodejs
    port: 8081
  kip:
    name: "What's Up, Kip?"
    uri: /kip
    shortname: kip
    bin: /usr/bin/node
    script: /var/www/nodejs/kip.js
    docroot: /var/www/nodejs
    port: 8082
