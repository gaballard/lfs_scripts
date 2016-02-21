cd $LFS/sources
tar -xvf gzip-1.6.tar.*
cd gzip-1.6
./configure --prefix=/tools
make
make install
cd ..
rm -rf gzip-1.6