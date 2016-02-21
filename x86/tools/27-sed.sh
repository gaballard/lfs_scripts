cd $LFS/sources
tar -xvf sed-4.2.2.tar.*
cd sed-4.2.2
./configure --prefix=/tools
make
make install
cd ..
rm -rf sed-4.2.2