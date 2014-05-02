apt-get install libgmp-dev libgmp10-doc libmpfr-dev libmpfr-doc libmpc-dev
mkdir gcc-4.9.0
wget ftp://ftp.lip6.fr/pub/gcc/releases/gcc-4.9.0/gcc-4.9.0.tar.bz2
tar xf gcc-4.9.0.tar.bz2
mv gcc-4.9.0 gcc-src
mkdir gcc-obj gcc-install
cd gcc-obj
../gcc-src/configure --prefix=${PWD}/../gcc-install --enable-languages="c,c++" --disable-multilib
export MAKE='make -j 10'
make
make install
