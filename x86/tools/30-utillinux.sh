cd $LFS/sources
tar -xvf util-linux-2.27.1.tar.*
cd util-linux-2.27.1
./configure --prefix=/tools                \
            --without-python               \
            --disable-makeinstall-chown    \
            --without-systemdsystemunitdir \
            PKG_CONFIG=""
make
make install
cd ..
rm -rf util-linux-2.27.1