cd $LFS/sources
tar -xvf make-4.1.tar.*
cd make-4.1
./configure --prefix=/tools --without-guile
make
make install
cd ..
rm -rf make-4.1