cd $LFS/sources
tar -xvf diffutils-3.3.tar.*
cd diffutils-3.3
./configure --prefix=/tools
make
make install
cd ..
rm -rf diffutils-3.3