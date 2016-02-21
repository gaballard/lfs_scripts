cd $LFS/sources
tar -xvf bzip2-1.0.6.tar.*
cd bzip2-1.0.6
make
make PREFIX=/tools install
cd ..
rm -rf bzip2-1.0.6