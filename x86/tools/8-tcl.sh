cd $LFS/sources
tar -xvf tcl-core8.6.4-src.tar.gz
cd tcl-core8.6.4-src
cd unix
./configure --prefix=/tools
make
make install
chmod -v u+w /tools/lib/libtcl8.6.so
make install-private-headers
ln -sv tclsh8.6 /tools/bin/tclsh
cd ..
rm -rf tcl-core8.6.4-src

tar -xvf expect5.45.tar.gz
cd expect5.45
cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure
./configure --prefix=/tools       \
            --with-tcl=/tools/lib \
            --with-tclinclude=/tools/include
make
make SCRIPTS="" install

cd ..
rm -rf expect5.45

tar -xvf dejagnu-1.5.3.tar.gz
cd dejagnu-1.5.3
./configure --prefix=/tools
make install
cd ..
rm -rf dejagnu-1.5.3

tar -xvf check-0.10.0.tar.gz
cd check-0.10.0
PKG_CONFIG= ./configure --prefix=/tools
make
make install
cd ..
rm -rf check-0.10.0

tar -xvf ncurses-6.0.tar.gz
cd ncurses-6.0
sed -i s/mawk// configure
./configure --prefix=/tools \
            --with-shared   \
            --without-debug \
            --without-ada   \
            --enable-widec  \
            --enable-overwrite
make
make install            
cd ..
rm -rf ncurses-6.0

tar -xvf bash-4.3.30.tar.gz
cd bash-4.3.30
./configure --prefix=/tools --without-bash-malloc
make
make install
ln -sv bash /tools/bin/sh
cd ..
rm -rf bash-4.3.30

tar -xvf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6
make
make PREFIX=/tools install
cd ..
rm -rf bzip2-1.0.6

tar -xvf coreutils-8.25.tar.xz
cd coreutils-8.25
./configure --prefix=/tools --enable-install-program=hostname
make
make RUN_EXPENSIVE_TESTS=yes check
make install
cd ..
rm -rf coreutils-8.25

tar -xvf diffutils-3.3.tar.xz
cd diffutils-3.3
./configure --prefix=/tools
make
make install
cd ..
rm -rf diffutils-3.3

tar -xvf file-5.25.tar.gz
cd file-5.25
./configure --prefix=/tools
make
make install
cd ..
rm -rf file-5.25

tar -xvf findutils-4.6.0.tar.gz
cd findutils-4.6.0
./configure --prefix=/tools
make
make install
cd ..
rm -rf findutils-4.6.0

tar -xvf gawk-4.1.3.tar.xz
cd gawk-4.1.3
./configure --prefix=/tools
make
make install
cd ..
rm -rf gawk-4.1.3

tar -xvf gettext-0.19.7.tar.xz
cd gettext-0.19.7
cd gettext-tools
EMACS="no" ./configure --prefix=/tools --disable-shared
make -C gnulib-lib
make -C intl pluralx.c
make -C src msgfmt
make -C src msgmerge
make -C src xgettext
cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin
cd ..
rm -rf gettext-0.19.7

tar -xvf grep-2.23.tar.xz
cd grep-2.23
./configure --prefix=/tools
make
make install
cd ..
rm -rf grep-2.23

tar -xvf gzip-1.6.tar.xz
cd gzip-1.6
./configure --prefix=/tools
make
make install
cd ..
rm -rf gzip-1.6

tar -xvf m4-1.4.17.tar.xz
cd m4-1.4.17
./configure --prefix=/tools
make
make install
cd ..
rm -rf m4-1.4.17

tar -xvf make-4.1.tar.bz2
cd make-4.1
./configure --prefix=/tools --without-guile
make
make install
cd ..
rm -rf make-4.1

tar -xvf patch-2.7.5.tar.xz
cd patch-2.7.5
./configure --prefix=/tools
make
make install
cd ..
rm -rf patch-2.7.5

tar -xvf perl-5.22.1.tar.bz2
cd perl-5.22.1
sh Configure -des -Dprefix=/tools -Dlibs=-lm
make
cp -v perl cpan/podlators/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.22.1
cp -Rv lib/* /tools/lib/perl5/5.22.1
cd ..
rm -rf perl-5.22.1

tar -xvf sed-4.2.2.tar.bz2
cd sed-4.2.2
./configure --prefix=/tools
make
make install
cd ..
rm -rf sed-4.2.2

tar -xvf tar-1.28.tar.xz
cd tar-1.28
./configure --prefix=/tools
make
make install
cd ..
rm -rf tar-1.28

tar -xvf texinfo-6.1.tar.xz
cd texinfo-6.1
./configure --prefix=/tools
make
make install
cd ..
rm -rf texinfo-6.1

tar -xvf util-linux-2.27.1.tar.xz
cd util-linux-2.27.1
./configure --prefix=/tools                \
            --without-python               \
            --disable-makeinstall-chown    \
            --without-systemdsystemunitdir \
            PKG_CONFIG=""
make
make install
cd ..
rm -rf util-linux-2.27.1

tar -xvf xz-5.2.2.tar.xz
cd xz-5.2.2
./configure --prefix=/tools
make
make install
cd ..
rm -rf xz-5.2.2

strip --strip-debug /tools/lib/*
/usr/bin/strip --strip-unneeded /tools/{,s}bin/*

rm -rf /tools/{,share}/{info,man,doc}

exit

chown -R root:root $LFS/tools