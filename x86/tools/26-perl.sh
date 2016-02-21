cd $LFS/sources
tar -xvf perl-5.22.1.tar.*
cd perl-5.22.1
sh Configure -des -Dprefix=/tools -Dlibs=-lm
make
cp -v perl cpan/podlators/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.22.1
cp -Rv lib/* /tools/lib/perl5/5.22.1
cd ..
rm -rf perl-5.22.1