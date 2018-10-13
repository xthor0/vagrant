#!/bin/bash

if [ -f "/etc/pki/tls/certs/{{ servername }}.crt" ]; then
    echo "SSL cert already exists."
    exit 0
fi

openssl req -new -sha256 -nodes -out /tmp/{{ servername }}.csr -newkey rsa:2048 -keyout /etc/pki/tls/private/{{ servername }}.key -config <(
cat <<-EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C=US
ST=Utah
L=Midvale
O=CHG Healthcare
OU=IT
CN = {{ servername }}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = {{ servername }}
EOF
)

if [ $? -eq 0 ]; then
    openssl x509 -req -days 365 -in /tmp/{{ servername }}.csr -signkey /etc/pki/tls/private/{{ servername }}.key -out /etc/pki/tls/certs/{{ servername }}.crt && rm -f /tmp/{{ servername }}.csr
    if [ $? -ne 0 ]; then
        echo "Error signing SSL certificate."
        exit 255
    else
        chmod 600 /etc/pki/tls/private/{{ servername }}.key
        chmod 644 /etc/pki/tls/certs/{{ servername }}.crt
    fi
else
    echo "Error generating CSR."
    exit 255
fi

exit 0