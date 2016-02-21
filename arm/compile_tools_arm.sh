arch-chroot /mnt /bin/bash

mkdir -p /mnt/clfs
export CLFS=/mnt/clfs
chmod 777 ${CLFS}
mkdir -v ${CLFS}/sources

wget --input-file=http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.bz2 --continue --directory-prefix=$CLFS/sources
wget --input-file=http://busybox.net/downloads/busybox-1.22.1.tar.bz2  --continue --directory-prefix=$CLFS/sources
wget --input-file=http://git.clfs.org/?p=bootscripts-embedded.git;a=snapshot;h=HEAD;sf=tgz --continue --directory-prefix=$CLFS/sources
wget --input-file=ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.7.3/gcc-4.7.3.tar.bz2 --continue --directory-prefix=$CLFS/sources
wget --input-file=http://ftp.gnu.org/gnu/gmp/gmp-5.1.2.tar.bz2 --continue --directory-prefix=$CLFS/sources
wget --input-file=http://sethwklein.net/iana-etc-2.30.tar.bz2 --continue --directory-prefix=$CLFS/sources
wget --input-file=http://www.kernel.org/pub/linux/kernel/v3.x/linux-3.0.80.tar.bz2 --continue --directory-prefix=$CLFS/sources
wget --input-file=http://www.multiprecision.org/mpc/download/mpc-1.0.1.tar.gz --continue --directory-prefix=$CLFS/sources
wget --input-file=http://gforge.inria.fr/frs/download.php/32210/mpfr-3.1.2.tar.bz2 --continue --directory-prefix=$CLFS/sources
wget --input-file=http://www.musl-libc.org/releases/musl-1.0.3.tar.gz --continue --directory-prefix=$CLFS/sources
wget --input-file=http://patches.clfs.org/embedded-dev/gcc-4.7.3-musl-1.patch --continue --directory-prefix=$CLFS/sources
wget --input-file=http://patches.clfs.org/embedded-dev/iana-etc-2.30-update-2.patch --continue --directory-prefix=$CLFS/sources

sudo groupadd clfs
sudo useradd -s /bin/bash -g clfs -m -k /dev/null clfs

sudo passwd clfs

sudo chown -Rv clfs ${CLFS}

su - clfs

cat > ~/.bash_profile << "EOF"
exec env -i HOME=${HOME} TERM=${TERM} PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
CLFS=/mnt/clfs
LC_ALL=POSIX
PATH=${CLFS}/cross-tools/bin:/bin:/usr/bin
export CLFS LC_ALL PATH
EOF

source ~/.bash_profile

unset CFLAGS
echo unset CFLAGS >> ~/.bashrc

export CLFS_FLOAT="hard"
export CLFS_FPU="vfpv4-d16"

export CLFS_HOST=$(echo ${MACHTYPE} | sed "s/-[^-]*/-cross/")
export CLFS_TARGET="arm-linux-musleabihf"

export CLFS_ARCH=arm
export CLFS_ARM_ARCH="armv7-a"

echo export CLFS_HOST=\""${CLFS_HOST}\"" >> ~/.bashrc
echo export CLFS_TARGET=\""${CLFS_TARGET}\"" >> ~/.bashrc
echo export CLFS_ARCH=\""${CLFS_ARCH}\"" >> ~/.bashrc
echo export CLFS_ARM_ARCH=\""${CLFS_ARM_ARCH}\"" >> ~/.bashrc
echo export CLFS_FLOAT=\""${CLFS_FLOAT}\"" >> ~/.bashrc
echo export CLFS_FPU=\""${CLFS_FPU}\"" >> ~/.bashrc

mkdir -p ${CLFS}/cross-tools/${CLFS_TARGET}
ln -sfv . ${CLFS}/cross-tools/${CLFS_TARGET}/usr

cd $CLFS/sources

tar -xvf linux-3.0.80.tar.bz2
cd linux-3.0.80
make mrproper
make ARCH=${CLFS_ARCH} headers_check
make ARCH=${CLFS_ARCH} INSTALL_HDR_PATH=${CLFS}/cross-tools/${CLFS_TARGET} headers_install
cd ..
rm -rf linux-3.0.80

tar -xvf binutils-2.24.tar.bz2
cd binutils-2.24
mkdir -v ../binutils-build
cd ../binutils-build
../binutils-2.24/configure \
   --prefix=${CLFS}/cross-tools \
   --target=${CLFS_TARGET} \
   --with-sysroot=${CLFS}/cross-tools/${CLFS_TARGET} \
   --disable-nls \
   --disable-multilib
make configure-host
make
make install
cd ..
rm -rf binutils-2.24
rm -rf binutils-build

tar -xvf gcc-4.7.3.tar.bz2
cd gcc-4.7.3
patch -Np1 -i ../gcc-4.7.3-musl-1.patch
tar xf ../mpfr-3.1.2.tar.bz2
mv -v mpfr-3.1.2 mpfr
tar xf ../gmp-5.1.2.tar.bz2
mv -v gmp-5.1.2 gmp
tar xf ../mpc-1.0.1.tar.gz
mv -v mpc-1.0.1 mpc
mkdir -v ../gcc-build
cd ../gcc-build
../gcc-4.7.3/configure \
  --prefix=${CLFS}/cross-tools \
  --build=${CLFS_HOST} \
  --host=${CLFS_HOST} \
  --target=${CLFS_TARGET} \
  --with-sysroot=${CLFS}/cross-tools/${CLFS_TARGET} \
  --disable-nls \
  --disable-shared \
  --without-headers \
  --with-newlib \
  --disable-decimal-float \
  --disable-libgomp \
  --disable-libmudflap \
  --disable-libssp \
  --disable-libatomic \
  --disable-libquadmath \
  --disable-threads \
  --enable-languages=c \
  --disable-multilib \
  --with-mpfr-include=$(pwd)/../gcc-4.7.3/mpfr/src \
  --with-mpfr-lib=$(pwd)/mpfr/src/.libs \
  --with-arch=${CLFS_ARM_ARCH} \
  --with-float=${CLFS_FLOAT} \
  --with-fpu=${CLFS_FPU}
make all-gcc all-target-libgcc
make install-gcc install-target-libgcc
cd ..
rm -rf gcc-4.7.3
rm -rf gcc-build

tar -xvf musl-1.0.3.tar.gz
cd musl-1.0.3
CC=${CLFS_TARGET}-gcc ./configure \
  --prefix=/ \
  --target=${CLFS_TARGET}
CC=${CLFS_TARGET}-gcc make
DESTDIR=${CLFS}/cross-tools/${CLFS_TARGET} make install
cd ..
rm -rf musl-1.0.3

tar -xvf gcc-4.7.3.tar.bz2
cd gcc-4.7.3
patch -Np1 -i ../gcc-4.7.3-musl-1.patch
tar xf ../mpfr-3.1.2.tar.bz2
mv -v mpfr-3.1.2 mpfr
tar xf ../gmp-5.1.2.tar.bz2
mv -v gmp-5.1.2 gmp
tar xf ../mpc-1.0.1.tar.gz
mv -v mpc-1.0.1 mpc
mkdir -v ../gcc-build
cd ../gcc-build
../gcc-4.7.3/configure \
  --prefix=${CLFS}/cross-tools \
  --build=${CLFS_HOST} \
  --target=${CLFS_TARGET} \
  --host=${CLFS_HOST} \
  --with-sysroot=${CLFS}/cross-tools/${CLFS_TARGET} \
  --disable-nls \
  --enable-languages=c \
  --enable-c99 \
  --enable-long-long \
  --disable-libmudflap \
  --disable-multilib \
  --with-mpfr-include=$(pwd)/../gcc-4.7.3/mpfr/src \
  --with-mpfr-lib=$(pwd)/mpfr/src/.libs \
  --with-arch=${CLFS_ARM_ARCH} \
  --with-float=${CLFS_FLOAT} \
  --with-fpu=${CLFS_FPU}
make
make install
rm -rf gcc-4.7.3
rm -rf gcc-build

echo export CC=\""${CLFS_TARGET}-gcc\"" >> ~/.bashrc
echo export CXX=\""${CLFS_TARGET}-g++\"" >> ~/.bashrc
echo export AR=\""${CLFS_TARGET}-ar\"" >> ~/.bashrc
echo export AS=\""${CLFS_TARGET}-as\"" >> ~/.bashrc
echo export LD=\""${CLFS_TARGET}-ld\"" >> ~/.bashrc
echo export RANLIB=\""${CLFS_TARGET}-ranlib\"" >> ~/.bashrc
echo export READELF=\""${CLFS_TARGET}-readelf\"" >> ~/.bashrc
echo export STRIP=\""${CLFS_TARGET}-strip\"" >> ~/.bashrc
source ~/.bashrc