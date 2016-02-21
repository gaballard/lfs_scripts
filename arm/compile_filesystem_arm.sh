mkdir -pv ${CLFS}/targetfs/{bin,boot,dev,etc,home,lib/{firmware,modules}}
mkdir -pv ${CLFS}/targetfs/{mnt,opt,proc,sbin,srv,sys}
mkdir -pv ${CLFS}/targetfs/var/{cache,lib,local,lock,log,opt,run,spool}
install -dv -m 0750 ${CLFS}/targetfs/root
install -dv -m 1777 ${CLFS}/targetfs/tmp
mkdir -pv ${CLFS}/targetfs/usr/{,local/}{bin,include,lib,sbin,share,src}

ln -svf ../proc/mounts ${CLFS}/targetfs/etc/mtab

cat > ${CLFS}/targetfs/etc/passwd << "EOF"
root::0:0:root:/root:/bin/ash
bin:x:1:1:bin:/bin:/bin/false
daemon:x:2:6:daemon:/sbin:/bin/false
mail:x:30:30:mail:/var/mail:/bin/false
uucp:x:32:32:uucp:/var/spool/uucp:/bin/false
operator:x:50:0:operator:/root:/bin/ash
postmaster:x:51:30:postmaster:/var/spool/mail:/bin/false
nobody:x:65534:65534:nobody:/:/bin/false
EOF

cat > ${CLFS}/targetfs/etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:4:
tape:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:root,adm,daemon
console:x:17:
mail:x:30:mail
uucp:x:32:uucp
users:x:100:
nogroup:x:65533:
nobody:x:65534:
EOF

touch ${CLFS}/targetfs/var/run/utmp ${CLFS}/targetfs/var/log/{btmp,lastlog,wtmp}
chmod -v 664 ${CLFS}/targetfs/var/run/utmp ${CLFS}/targetfs/var/log/lastlog

cd $CLFS/sources

tar -xvf busybox-1.22.1.tar.bz2
cd busybox-1.22.1
make distclean
ARCH="${CLFS_ARCH}" make defconfig
sed -i 's/\(CONFIG_\)\(.*\)\(INETD\)\(.*\)=y/# \1\2\3\4 is not set/g' .config
sed -i 's/\(CONFIG_IFPLUGD\)=y/# \1 is not set/' .config
ARCH="${CLFS_ARCH}" CROSS_COMPILE="${CLFS_TARGET}-" make
ARCH="${CLFS_ARCH}" CROSS_COMPILE="${CLFS_TARGET}-" make  \
  CONFIG_PREFIX="${CLFS}/targetfs" install
cp examples/depmod.pl ${CLFS}/cross-tools/bin
chmod 755 ${CLFS}/cross-tools/bin/depmod.pl
cd ..
rm -rf busybox-1.22.1

tar -xvf iana-etc-2.30.tar.bz2
cd iana-etc-2.30
patch -Np1 -i ../iana-etc-2.30-update-2.patch
make get
make STRIP=yes
make DESTDIR=${CLFS}/targetfs install
cd ..
rm -rf iana-etc-2.30