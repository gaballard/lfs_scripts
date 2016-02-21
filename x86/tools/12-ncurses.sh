cd $LFS/sources
tar -xvf ncurses-6.0.tar.*
cd ncurses-6.0
sed -i s/mawk// configure
./configure --prefix=/tools \
            --with-shared   \
            --without-debug \
            --without-ada   \
            --enable-widec  \
            --enable-overwrite
make
make install
cd ..
rm -rf ncurses-6.0