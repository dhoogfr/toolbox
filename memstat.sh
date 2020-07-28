#!/bin/bash
#set -x
[ "$1" = '--oneshot' ] && ONESHOT="yes" || ONESHOT="no"
PAGESIZE=30
SLEEP_TIME=3
[ $ONESHOT = "no" ] && printf "          Free          Shmem  Mapped+Cached           Anon     Pagetables    KernelStack        Buffers           Slab       SwpCache        HP Used        HP Rsvd        HP Free        Unknown   %%\n"
ROWCOUNTER=0
while ( true ); do
  # 1 get meminfo
  MEMINFO=$( cat /proc/meminfo )
  # 2 get relevant data
  MEMTOTAL=$( echo "$MEMINFO" | awk '/^MemTotal/ { print $2 }')
  MEMFREE=$( echo "$MEMINFO" | awk '/^MemFree/ { print $2 }')
  KERNELSTACK=$( echo "$MEMINFO" | awk '/^KernelStack/ { print $2 }')
  BUFFERS=$( echo "$MEMINFO" | awk '/^Buffers/ { print $2 }')
  CACHED=$( echo "$MEMINFO" | awk '/^Cached/ { print $2 }')
  PAGETABLES=$( echo "$MEMINFO" | awk '/^PageTables/ { print $2 }')
  SHMEM=$( echo "$MEMINFO" | awk '/^Shmem:/ { print $2 }')
  ANONPAGES=$( echo "$MEMINFO" | awk '/^AnonPages/ { print $2 }')
  SLAB=$( echo "$MEMINFO" | awk '/^Slab/ { print $2 }')
  SWAPCACHED=$( echo "$MEMINFO" | awk '/^SwapCached/ { print $2 }')
  # hugepages are expressed in pages, not KB
  HP_TOTAL=$( echo "$MEMINFO" | awk '/^HugePages_Total/ { print $2 }')
  HP_RSVD=$( echo "$MEMINFO" | awk '/^HugePages_Rsvd/ { print $2 }')
  HP_FREE=$( echo "$MEMINFO" | awk '/^HugePages_Free/ { print $2 }')
  HP_SIZE=$( echo "$MEMINFO" | awk '/^Hugepagesize/ { print $2 }')
  # swap
  SWAP_TOTAL=$( echo "$MEMINFO" | awk '/^SwapTotal/ { print $2 }')
  SWAP_FREE=$( echo "$MEMINFO" | awk '/^SwapFree/ { print $2 }')
  # 3 define final data
  # MEMTOTAL
  # MEMFREE
  # KERNELSTACK
  # BUFFERS
  CACHED=$(( $CACHED-$SHMEM ))
  # PAGETABLES
  # SHMEM
  # ANONPAGES
  # SLAB
  # SWAPCACHED
  HP_USED_KB=$(( ($HP_TOTAL-$HP_FREE)*$HP_SIZE ))
  HP_RSVD_KB=$(( $HP_RSVD*$HP_SIZE ))
  HP_REALFREE_KB=$(( ($HP_FREE-$HP_RSVD)*$HP_SIZE ))
  SWAP_USED=$(( $SWAP_TOTAL-$SWAP_FREE ))
  SWAP_PCT=$(( ($SWAP_USED*100)/$SWAP_TOTAL ))
  #
  ACCT_FOR_MEM_TOTAL=$(( $MEMFREE+$KERNELSTACK+$BUFFERS+$CACHED+$PAGETABLES+$SHMEM+$MAPPED+$ANONPAGES+$SLAB+$SWAPCACHED+$HP_USED_KB+$HP_RSVD_KB+$HP_REALFREE_KB ))
  UNACCT_FOR=$(( $MEMTOTAL-$ACCT_FOR_MEM_TOTAL ))
  UA_PCT=$(( ($UNACCT_FOR*100)/$MEMTOTAL ))
  if [ $ONESHOT = "no" ]; then
    # visualize
    printf "%14d %14d %14d %14d %14d %14d %14d %14d %14d %14d %14d %14d %14d %3d\n" $MEMFREE $SHMEM $CACHED $ANONPAGES $PAGETABLES $KERNELSTACK $BUFFERS $SLAB $SWAPCACHED $HP_USED_KB $HP_RSVD_KB $HP_REALFREE_KB $UNACCT_FOR $UA_PCT
    sleep $SLEEP_TIME
    let ROWCOUNTER++
    if (( $ROWCOUNTER % $PAGESIZE == 0 )); then
      printf "          Free          Shmem  Mapped+Cached           Anon     Pagetables    KernelStack        Buffers           Slab       SwpCache        HP Used        HP Rsvd        HP Free        Unknown   %%\n"
    fi
  fi
  if [ $ONESHOT = "yes" ]; then
    printf "Free         %14d\nShmem        %14d\nMapped+Cached%14d\nAnon         %14d\nPagetables   %14d\nKernelStack  %14d\nBuffers      %14d\nSlab         %14d\nSwpCache     %14d\nHP Used      %14d\nHP Rsvd      %14d\nHP Free      %14d\nUnknown      %14d (%3d%%)\nTotal memory %14d\n---------------------------\nTotal swp    %14d\nUsed swp     %14d (%3d%%)\n" $MEMFREE $SHMEM $CACHED $ANONPAGES $PAGETABLES $KERNELSTACK $BUFFERS $SLAB $SWAPCACHED $HP_USED_KB $HP_RSVD_KB $HP_REALFREE_KB $UNACCT_FOR $UA_PCT $MEMTOTAL $SWAP_TOTAL $SWAP_USED $SWAP_PCT
    break
  fi
done

