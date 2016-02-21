cd $LFS/sources
tar -xvf file-5.25.tar.*
cd file-5.25
./configure --prefix=/tools
make
make install
cd ..
rm -rf file-5.25