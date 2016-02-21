tar -xvf linux-4.4.1.tar.xz
cd linux-4.4.1
make mrproper
make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* /tools/include
cd ..
rm -rf linux-4.4.1