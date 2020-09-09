#!/usr/bin/env bash

### check which root CA was used to sign the certificate of a given https website
### get that root certificate from the Mozilla certificate bundle on the server
### and store it in the current working directory
###
### this certificate can then be imported into an oracle wallet or used for other purposes

chain=$(openssl s_client -connect ${1}:443 <<< . 2>&1|awk '/^Certificate chain$/,/---/')
echo "${chain}"
root_ca=$(echo "${chain}" | tail -2 | head -1 | awk -F '=' '{print $(NF)}')
echo "root CA: " ${root_ca}
awk "/^# ${root_ca}$/,/END TRUSTED CERTIFICATE/" /etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt | head -n -1 | tail -n +3 | awk 'BEGIN {print "-----BEGIN CERTIFICATE-----"} {print $0} END{print "-----END CERTIFICATE-----"}' | tee $(echo "${root_ca}" | tr ' ' '_').crt

