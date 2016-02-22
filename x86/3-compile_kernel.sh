tar -xvf linux-4.4.2.tar.xz
cd linux-4.4.2
make mrproper
make INSTALL_HDR_PATH=dest headers_install
find dest/include \( -name .install -o -name ..install.cmd \) -delete
cp -rv dest/include/* /usr/include
cd ..
rm -rf linux-4.4.2

tar -xvf man-pages-4.04.tar.*
cd man-pages-4.04
make install
cd ..
rm -rf man-pages-4.04

tar -xvf glibc-2.23.tar.xz
cd glibc-2.23
patch -Np1 -i ../glibc-2.23-fhs-1.patch
mkdir -v build
cd       build
../configure --prefix=/usr          \
             --disable-profile      \
             --enable-kernel=2.6.32 \
             --enable-obsolete-rpc
make
make check
touch /etc/ld.so.conf
make install
cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd
mkdir -pv /usr/lib/locale
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
make localedata/install-locales
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF
tar -xf ../../tzdata2016a.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward pacificnew systemv; do
    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/Los_Angeles
unset ZONEINFO
cp -v /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF
cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d

cd ..
rm -rf glibc-2.23

mv -v /tools/bin/{ld,ld-old}
mv -v /tools/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}
mv -v /tools/bin/{ld-new,ld}
ln -sv /tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld

gcc -dumpspecs | sed -e 's@/tools@@g'                   \
    -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
    -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
    `dirname $(gcc --print-libgcc-file-name)`/specs

echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'

grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log

grep -B1 '^ /usr/include' dummy.log

grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

grep "/lib.*/libc.so.6 " dummy.log

grep found dummy.log

rm -v dummy.c a.out dummy.log

tar -xvf zlib-1.2.8.tar.xz
cd zlib-1.2.8
./configure --prefix=/usr
make
make check
make install
mv -v /usr/lib/libz.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so
cd ..
rm -rf zlib-1.2.8

tar -xvf file-5.25.tar.gz
cd file-5.25
./configure --prefix=/usr
make
make check
make install
cd ..
rm -rf file-5.25

tar -xvf binutils-2.26.tar.bz2
cd binutils-2.26
expect -c "spawn ls"
patch -Np1 -i ../binutils-2.26-upstream_fix-2.patch
mkdir -v build
cd       build
../configure --prefix=/usr   \
             --enable-shared \
             --disable-werror
make tooldir=/usr
make check
make tooldir=/usr install
cd ..
rm -rf binutils-2.26

tar -xvf gmp-6.1.0.tar.xz
cd gmp-6.1.0
./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.1.0
make
make html
make check 2>&1 | tee gmp-check-log
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
make install
make install-html
cd ..
rm -rf gmp-6.1.0

tar -xvf mpfr-3.1.3.tar.xz
cd mpfr-3.1.3
patch -Np1 -i ../mpfr-3.1.3-upstream_fixes-2.patch
./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-3.1.3
make
make html
make check
make install
make install-html
cd ..
rm -rf mpfr-3.1.3

tar -xvf mpc-1.0.3.tar.gz
cd mpc-1.0.3
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.0.3
make
make html
make check
make install
make install-html
cd ..
rm -rf mpc-1.0.3

tar -xvf gcc-5.3.0.tar.bz2
cd gcc-5.3.0
mkdir -v build
cd       build
SED=sed                               \
../configure --prefix=/usr            \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib
make
ulimit -s 32768
make -k check
../contrib/test_summary
make install
ln -sv ../usr/bin/cpp /lib
ln -sv gcc /usr/bin/cc
install -v -dm755 /usr/lib/bfd-plugins
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/5.3.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/
echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'
grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
grep -B4 '^ /usr/include' dummy.log
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " dummy.log
grep found dummy.log
rm -v dummy.c a.out dummy.log
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
cd ..
rm -rf gcc-5.3.0

tar -xvf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6
patch -Np1 -i ../bzip2-1.0.6-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so
make clean
make
make PREFIX=/usr install
cp -v bzip2-shared /bin/bzip2
cp -av libbz2.so* /lib
ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
rm -v /usr/bin/{bunzip2,bzcat,bzip2}
ln -sv bzip2 /bin/bunzip2
ln -sv bzip2 /bin/bzcat
cd ..
rm -rf bzip2-1.0.6

tar -xvf pkg-config-0.29.tar.gz
cd pkg-config-0.29
./configure --prefix=/usr        \
            --with-internal-glib \
            --disable-host-tool  \
            --docdir=/usr/share/doc/pkg-config-0.29
make
make check
make install
cd ..
rm -rf pkg-config-0.29

tar -xvf ncurses-6.0.tar.gz
cd ncurses-6.0
sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --enable-pc-files       \
            --enable-widec
make
make install
mv -v /usr/lib/libncursesw.so.6* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so
for lib in ncurses form panel menu ; do
    rm -vf                    /usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
done
rm -vf                     /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so      /usr/lib/libcurses.so
mkdir -v       /usr/share/doc/ncurses-6.0
cp -v -R doc/* /usr/share/doc/ncurses-6.0

cd ..
rm -rf ncurses-6.0

tar -xvf attr-2.4.47.src.tar.gz
cd attr-2.4.47
sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
sed -i -e "/SUBDIRS/s|man2||" man/Makefile
./configure --prefix=/usr \
            --bindir=/bin \
            --disable-static
make
make -j1 tests root-tests
make install install-dev install-lib
chmod -v 755 /usr/lib/libattr.so
mv -v /usr/lib/libattr.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so
cd ..
rm -rf attr-2.4.47

tar -xvf acl-2.2.52.src.tar.gz
cd acl-2.2.52
sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
sed -i "s:| sed.*::g" test/{sbits-restore,cp,misc}.test
sed -i -e "/TABS-1;/a if (x > (TABS-1)) x = (TABS-1);" \
    libacl/__acl_to_any_text.c
./configure --prefix=/usr    \
            --bindir=/bin    \
            --disable-static \
            --libexecdir=/usr/lib
make
make install install-dev install-lib
chmod -v 755 /usr/lib/libacl.so
mv -v /usr/lib/libacl.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so
cd ..
rm -rf acl-2.2.52

tar -xvf libcap-2.25.tar.xz
cd libcap-2.25
sed -i '/install.*STALIBNAME/d' libcap/Makefile
make
make RAISE_SETFCAP=no prefix=/usr install
chmod -v 755 /usr/lib/libcap.so
mv -v /usr/lib/libcap.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libcap.so) /usr/lib/libcap.so
cd ..
rm -rf libcap-2.25

tar -xvf sed-4.2.2.tar.bz2
cd sed-4.2.2
./configure --prefix=/usr --bindir=/bin --htmldir=/usr/share/doc/sed-4.2.2
make
make html
make check
make install
make -C doc install-html
cd ..
rm -rf sed-4.2.2

tar -xvf shadow-4.2.1.tar.xz
cd shadow-4.2.1
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;
sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs
sed -i 's/1000/999/' etc/useradd
./configure --sysconfdir=/etc --with-group-name-max-length=32
make
make install
mv -v /usr/bin/passwd /bin
pwconv
grpconv
passwd root
cd ..
rm -rf shadow-4.2.1

tar -xvf psmisc-22.21.tar.gz
cd psmisc-22.21
./configure --prefix=/usr
make
make install
mv -v /usr/bin/fuser   /bin
mv -v /usr/bin/killall /bin
cd ..
rm -rf psmisc-22.21

tar -xvf procps-ng-3.3.11.tar.xz
cd procps-ng-3.3.11
./configure --prefix=/usr                            \
            --exec-prefix=                           \
            --libdir=/usr/lib                        \
            --docdir=/usr/share/doc/procps-ng-3.3.11 \
            --disable-static                         \
            --disable-kill
make
sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp
make check
make install
mv -v /usr/lib/libprocps.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so
cd ..
rm -rf procps-ng-3.3.11

tar -xvf e2fsprogs-1.42.13.tar.gz
cd e2fsprogs-1.42.13
mkdir -v build
cd build
LIBS=-L/tools/lib                    \
CFLAGS=-I/tools/include              \
PKG_CONFIG_PATH=/tools/lib/pkgconfig \
../configure --prefix=/usr           \
             --bindir=/bin           \
             --with-root-prefix=""   \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck
make 
ln -sfv /tools/lib/lib{blk,uu}id.so.1 lib
make LD_LIBRARY_PATH=/tools/lib check
make install
make install-libs
chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
cd ..
rm -rf e2fsprogs-1.42.13

tar -xvf iana-etc-2.30.tar.bz2
cd iana-etc-2.30
make
make install
cd ..
rm -rf iana-etc-2.30

tar -xvf m4-1.4.17.tar.xz
cd m4-1.4.17
./configure --prefix=/usr
make
make check
make install
cd ..
rm -rf m4-1.4.17

tar -xvf bison-3.0.4.tar.xz
cd bison-3.0.4
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.0.4
make
make install
cd ..
rm -rf bison-3.0.4

tar -xvf flex-2.6.0.tar.xz
cd flex-2.6.0
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/flex-2.6.0
make
make check
make install
ln -sv flex /usr/bin/lex
cd ..
rm -rf flex-2.6.0

tar -xvf grep-2.23.tar.xz
cd grep-2.23
./configure --prefix=/usr --bindir=/bin
make
make check
make install
cd ..
rm -rf grep-2.23

tar -xvf readline-6.3.tar.gz
cd readline-6.3
patch -Np1 -i ../readline-6.3-upstream_fixes-3.patch
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/readline-6.3
make SHLIB_LIBS=-lncurses
make SHLIB_LIBS=-lncurses install
mv -v /usr/lib/lib{readline,history}.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-6.3
cd ..
rm -rf readline-6.3

tar -xvf bash-4.3.30.tar.gz
cd bash-4.3.30
patch -Np1 -i ../bash-4.3.30-upstream_fixes-3.patch
./configure --prefix=/usr                       \
            --docdir=/usr/share/doc/bash-4.3.30 \
            --without-bash-malloc               \
            --with-installed-readline
make
chown -Rv nobody .
su nobody -s /bin/bash -c "PATH=$PATH make tests"
make install
mv -vf /usr/bin/bash /bin
exec /bin/bash --login +h

cd ..
rm -rf bash-4.3.30

tar -xvf bc-1.06.95.tar.bz2
cd bc-1.06.95
patch -Np1 -i ../bc-1.06.95-memory_leak-1.patch
./configure --prefix=/usr           \
            --with-readline         \
            --mandir=/usr/share/man \
            --infodir=/usr/share/info
make
echo "quit" | ./bc/bc -l Test/checklib.b
make install
cd ..
rm -rf bc-1.06.95

tar -xvf libtool-2.4.6.tar.xz
cd libtool-2.4.6
./configure --prefix=/usr
make
make check
make install
cd ..
rm -rf libtool-2.4.6

tar -xvf gdbm-1.11.tar.gz
cd gdbm-1.11
./configure --prefix=/usr \
            --disable-static \
            --enable-libgdbm-compat
make
make check
make install
cd ..
rm -rf gdbm-1.11

tar -xvf expat-2.1.0.tar.gz
cd expat-2.1.0
./configure --prefix=/usr --disable-static
make
make check
make install
install -v -dm755 /usr/share/doc/expat-2.1.0
install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.1.0

cd ..
rm -rf expat-2.1.0

tar -xvf inetutils-1.9.4.tar.xz
cd inetutils-1.9.4
./configure --prefix=/usr        \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers
make
make check
make install
mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
mv -v /usr/bin/ifconfig /sbin
cd ..
rm -rf inetutils-1.9.4

tar -xvf perl-5.22.1.tar.bz2
cd perl-5.22.1
echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
export BUILD_ZLIB=False
export BUILD_BZIP2=0
sh Configure -des -Dprefix=/usr                 \
                  -Dvendorprefix=/usr           \
                  -Dman1dir=/usr/share/man/man1 \
                  -Dman3dir=/usr/share/man/man3 \
                  -Dpager="/usr/bin/less -isR"  \
                  -Duseshrplib
make
make -k test
make install
unset BUILD_ZLIB BUILD_BZIP2
cd ..
rm -rf perl-5.22.1

tar -xvf XML-Parser-2.44.tar.gz
cd XML-Parser-2.44
perl Makefile.PL
make
make test
make install
cd ..
rm -rf XML-Parser-2.44

tar -xvf autoconf-2.69.tar.xz
cd autoconf-2.69
./configure --prefix=/usr
make
make check
make install
cd ..
rm -rf autoconf-2.69

tar -xvf automake-1.15.tar.xz
cd automake-1.15
sed -i 's:/\\\${:/\\\$\\{:' bin/automake.in
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.15
make
sed -i "s:./configure:LEXLIB=/usr/lib/libfl.a &:" t/lex-{clean,depend}-cxx.sh
make -j4 check
make install
cd ..
rm -rf automake-1.15

tar -xvf coreutils-8.25.tar.xz
cd coreutils-8.25
patch -Np1 -i ../coreutils-8.25-i18n-2.patch
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime
FORCE_UNSAFE_CONFIGURE=1 make
make NON_ROOT_USERNAME=nobody check-root
echo "dummy:x:1000:nobody" >> /etc/group
chown -Rv nobody . 
su nobody -s /bin/bash \
          -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
sed -i '/dummy/d' /etc/group
make install
mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8
mv -v /usr/bin/{head,sleep,nice,test,[} /bin
cd ..
rm -rf coreutils-8.25

tar -xvf diffutils-3.3.tar.xz
cd diffutils-3.3
sed -i 's:= @mkdir_p@:= /bin/mkdir -p:' po/Makefile.in.in
./configure --prefix=/usr
make
make check
make install
cd ..
rm -rf diffutils-3.3

tar -xvf gawk-4.1.3.tar.xz
cd gawk-4.1.3
./configure --prefix=/usr
make
make check
make install
mkdir -v /usr/share/doc/gawk-4.1.3
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-4.1.3
cd ..
rm -rf gawk-4.1.3

tar -xvf findutils-4.6.0.tar.gz
cd findutils-4.6.0
./configure --prefix=/usr --localstatedir=/var/lib/locate
make
make check
make install
mv -v /usr/bin/find /bin
sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb
cd ..
rm -rf findutils-4.6.0

tar -xvf gettext-0.19.7.tar.xz
cd gettext-0.19.7
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.19.7
make
make check
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so
cd ..
rm -rf gettext-0.19.7

tar -xvf intltool-0.51.0.tar.gz
cd intltool-0.51.0
sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make
make check
make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
cd ..
rm -rf intltool-0.51.0

tar -xvf gperf-3.0.4.tar.gz
cd gperf-3.0.4
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.0.4
make
make -j1 check
make install
cd ..
rm -rf gperf-3.0.4

tar -xvf groff-1.22.3.tar.gz
cd groff-1.22.3
PAGE=<paper_size> ./configure --prefix=/usr
make
make install
cd ..
rm -rf groff-1.22.3

tar -xvf xz-5.2.2.tar.xz
cd xz-5.2.2
sed -e '/mf\.buffer = NULL/a next->coder->mf.size = 0;' \
     -i src/liblzma/lz/lz_encoder.c
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.2.2
make
make check
make install
mv -v   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
mv -v /usr/lib/liblzma.so.* /lib
ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so
cd ..
rm -rf xz-5.2.2

tar -xvf grub-2.02~beta2.tar.xz
cd grub-2.02~beta2
./configure --prefix=/usr          \
            --sbindir=/sbin        \
            --sysconfdir=/etc      \
            --disable-grub-emu-usb \
            --disable-efiemu       \
            --disable-werror
make
make install
cd ..
rm -rf grub-2.02~beta2

tar -xvf less-481.tar.gz
cd less-481
./configure --prefix=/usr --sysconfdir=/etc
make
make install
cd ..
rm -rf less-481

tar -xvf gzip-1.6.tar.xz
cd gzip-1.6
./configure --prefix=/usr --bindir=/bin
make
make check
make install
mv -v /bin/{gzexe,uncompress,zcmp,zdiff,zegrep} /usr/bin
mv -v /bin/{zfgrep,zforce,zgrep,zless,zmore,znew} /usr/bin
cd ..
rm -rf gzip-1.6

tar -xvf iproute2-4.4.0.tar.xz
cd iproute2-4.4.0
sed -i /ARPD/d Makefile
sed -i 's/arpd.8//' man/man8/Makefile
rm -v doc/arpd.sgml
make
make DOCDIR=/usr/share/doc/iproute2-4.4.0 install
cd ..
rm -rf iproute2-4.4.0

tar -xvf kbd-2.0.3.tar.xz
cd kbd-2.0.3
patch -Np1 -i ../kbd-2.0.3-backspace-1.patch
sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr --disable-vlock
make
make check
make install
mkdir -v       /usr/share/doc/kbd-2.0.3
cp -R -v docs/doc/* /usr/share/doc/kbd-2.0.3
cd ..
rm -rf kbd-2.0.3

tar -xvf kmod-22.tar.xz
cd kmod-22
./configure --prefix=/usr          \
            --bindir=/bin          \
            --sysconfdir=/etc      \
            --with-rootlibdir=/lib \
            --with-xz              \
            --with-zlib
make
make install

for target in depmod insmod lsmod modinfo modprobe rmmod; do
  ln -sv ../bin/kmod /sbin/$target
done

ln -sv kmod /bin/lsmod
cd ..
rm -rf kmod-22

tar -xvf libpipeline-1.4.1.tar.gz
cd libpipeline-1.4.1
PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr
make
make check
make install
cd ..
rm -rf libpipeline-1.4.1

tar -xvf make-4.1.tar.bz2
cd make-4.1
./configure --prefix=/usr
make
make check
make install
cd ..
rm -rf make-4.1

tar -xvf patch-2.7.5.tar.xz
cd patch-2.7.5
./configure --prefix=/usr
make
make check
make install
cd ..
rm -rf patch-2.7.5

tar -xvf sysklogd-1.5.1.tar.gz
cd sysklogd-1.5.1
sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
make
make BINDIR=/sbin install
cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf
EOF
cd ..
rm -rf sysklogd-1.5.1

tar -xvf sysvinit-2.88dsf.tar.bz2
cd sysvinit-2.88dsf

cd ..
rm -rf sysvinit-2.88dsf

tar -xvf 
cd 

cd ..
rm -rf 

tar -xvf 
cd 

cd ..
rm -rf 

tar -xvf 
cd 

cd ..
rm -rf 

tar -xvf 
cd 

cd ..
rm -rf 

tar -xvf 
cd 

cd ..
rm -rf 

tar -xvf 
cd 

cd ..
rm -rf 

tar -xvf 
cd 

cd ..
rm -rf 

tar -xvf 
cd 

cd ..
rm -rf 

