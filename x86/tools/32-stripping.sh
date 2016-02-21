cd $LFS/sources
strip --strip-debug /tools/lib/*
/usr/bin/strip --strip-unneeded /tools/{,s}bin/*
rm -rf /tools/{,share}/{info,man,doc}
echo 'STRIPPING COMPLETE'
echo 'RETURNING CONTROL TO ROOT...'
exit
chown -R root:root $LFS/tools