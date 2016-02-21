cd $LFS/sources
tar -xvf check-0.10.0.tar.*
cd check-0.10.0
PKG_CONFIG= ./configure --prefix=/tools
make
make install
cd ..
rm -rf check-0.10.0