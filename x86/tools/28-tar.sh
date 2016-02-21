cd $LFS/sources
tar -xvf tar-1.28.tar.*
cd tar-1.28
./configure --prefix=/tools
make
make install
cd ..
rm -rf tar-1.28