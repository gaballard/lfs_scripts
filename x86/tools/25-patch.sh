cd $LFS/sources
tar -xvf patch-2.7.5.tar.*
cd patch-2.7.5
./configure --prefix=/tools
make
make install
cd ..
rm -rf patch-2.7.5