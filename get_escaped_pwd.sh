#!/bin/bash

# grep the user passed as script parameter in /etc/shadow and prints is escaped encrypted password.
# to be used when recreating users with the encrypted password (when the actual password is not known)
# execute as root

grep $1 /etc/shadow | awk -F':' '{ gsub(/\$/,"\\$",$2); print $1 ": " $2 }'