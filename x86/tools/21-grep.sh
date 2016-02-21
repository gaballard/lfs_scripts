cd $LFS/sources
tar -xvf grep-2.23.tar.*
cd grep-2.23
./configure --prefix=/tools
make
make install
cd ..
rm -rf grep-2.23