!for i in `echo $SQLPATH | tr ':' ' '`; do find $i -iname "*&1*.sql" -exec basename {} \; ; done
