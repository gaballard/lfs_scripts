cd $LFS/sources
tar -xvf findutils-4.6.0.tar.*
cd findutils-4.6.0
./configure --prefix=/tools
make
make install
cd ..
rm -rf findutils-4.6.0