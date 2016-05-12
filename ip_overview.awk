ifconfig -a | awk -F '[ :]+' '
BEGIN { 
  printf "%10-s %15-s %15-s\n", "Interface", "IP Adress", "Mask"
  printf "%10-s %15-s %15-s\n", "----------", "---------------", "---------------"
}
{ if ($0 ~ "Link encap:") 
    { interface = $1 } 
  if ($0 ~ "inet addr") 
    { printf "%10-s %15-s %15-s\n", interface, $4, $8 }
}'
