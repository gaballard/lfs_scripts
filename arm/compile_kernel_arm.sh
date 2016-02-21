cat > ${CLFS}/targetfs/etc/fstab << "EOF"
# file-system  mount-point  type   options          dump  fsck
/dev/sdc2     /            ext4  defaults         1     1
EOF

tar -xvf linux-3.0.80.tar.bz2
cd linux-3.0.80
make mrproper
make ARCH=${CLFS_ARCH} CROSS_COMPILE=${CLFS_TARGET}- menuconfig
make ARCH=${CLFS_ARCH} CROSS_COMPILE=${CLFS_TARGET}-

make ARCH=${CLFS_ARCH} CROSS_COMPILE=${CLFS_TARGET}- \
    INSTALL_MOD_PATH=${CLFS}/targetfs modules_install


cd ..
rm -rf linux-3.0.80




#tar -xvf gmp-5.1.2.tar.bz2
#cd gmp-5.1.2
#
#cd ..
#rm -rf gmp-5.1.2
#
#tar -xvf mpc-1.0.1.tar.gz
#cd mpc-1.0.1
#
#cd ..
#rm -rf mpc-1.0.1
#
#tar -xvf mpfr-3.1.2.tar.bz2
#cd mpfr-3.1.2
#
#cd ..
#rm -rf mpfr-3.1.2
#
