cd $LFS/sources
tar -xvf xz-5.2.2.tar.*
cd xz-5.2.2
./configure --prefix=/tools
make
make install
cd ..
rm -rf xz-5.2.2