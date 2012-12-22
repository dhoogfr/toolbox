ps -ef | awk '{if (NR > 1) {users[$1]++}} END {for (user in users) { printf "%-20s %d\n", user, users[user]}}'
