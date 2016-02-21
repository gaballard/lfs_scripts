cd $LFS/sources
tar -xvf m4-1.4.17.tar.*
cd m4-1.4.17
./configure --prefix=/tools
make
make install
cd ..
rm -rf m4-1.4.17