cd $LFS/sources
tar -xvf gawk-4.1.3.tar.*
cd gawk-4.1.3
./configure --prefix=/tools
make
make install
cd ..
rm -rf gawk-4.1.3