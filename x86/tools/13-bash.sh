cd $LFS/sources
tar -xvf bash-4.3.30.tar.*
cd bash-4.3.30
./configure --prefix=/tools --without-bash-malloc
make
make install
ln -sv bash /tools/bin/sh
cd ..
rm -rf bash-4.3.30