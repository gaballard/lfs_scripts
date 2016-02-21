cd $LFS/sources
tar -xvf glibc-2.22.tar.xz
cd glibc-2.22
patch -Np1 -i ../glibc-2.22-upstream_i386_fix-1.patch
mkdir -v build
cd       build
../configure                             \
      --prefix=/tools                    \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --disable-profile                  \
      --enable-kernel=2.6.32             \
      --enable-obsolete-rpc              \
      --with-headers=/tools/include      \
      libc_cv_forced_unwind=yes          \
      libc_cv_ctors_header=yes           \
      libc_cv_c_cleanup=yes
make
make install
cd ..
rm -rf glibc-2.22