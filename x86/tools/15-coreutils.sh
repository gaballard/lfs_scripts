cd $LFS/sources
tar -xvf coreutils-8.25.tar.*
cd coreutils-8.25
./configure --prefix=/tools --enable-install-program=hostname
make
make install
cd ..
rm -rf coreutils-8.25