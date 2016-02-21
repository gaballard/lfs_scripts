cd $LFS/sources
tar -xvf expect-5.45.tar.*
cd expect-5.45
cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure
./configure --prefix=/tools       \
            --with-tcl=/tools/lib \
            --with-tclinclude=/tools/include
make
make SCRIPTS="" install
cd ..
rm -rf expect-5.45