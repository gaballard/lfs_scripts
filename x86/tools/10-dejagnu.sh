cd $LFS/sources
tar -xvf dejagnu-1.5.3.tar.*
cd dejagnu-1.5.3
./configure --prefix=/tools
make install
cd ..
rm -rf dejagnu-1.5.3