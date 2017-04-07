#!/bin/bash

ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 -oHostKeyAlgorithms=+ssh-dss -T oracle@sdtcsynoda02-rac -p 8002 <<< "backups list" | rev | grep -v -e '^       -' | rev

