#!/bin/bash
### get the ssl certificate send to the browser and store it in a file (for distribution)
### usage: first parameter is the hostname of the remote server, second is its port number and third is the output file

hostname=$1
port=$2
certfile=$3
echo -n | openssl s_client -connect ${hostname}:${port} | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${certfile}
