cd $LFS/sources
tar -xvf texinfo-6.1.tar.*
cd texinfo-6.1
./configure --prefix=/tools
make
make install
cd ..
rm -rf texinfo-6.1