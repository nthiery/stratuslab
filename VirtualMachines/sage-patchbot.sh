#!/bin/bash

# Author: Nicolas M. Thiéry

# Run the VM with:
# stratus-run-instance --cpu=8 --ram=4000 --swap==2000 --volatile-disk 20 --cloud-init 'ssh,$HOME/.ssh/id_rsa.pub#none,./initSage.sh' BsHnKXtlxejHFYIq1oTQvFE2sZy
# stratus-run-instance --cpu=8 --ram=4000 --swap==2000 --volatile-disk 20 BsHnKXtlxejHFYIq1oTQvFE2sZy
# stratus-run-instance --vm-name sage-patchbot --cpu=8 --ram=4000 --swap==2000 --volatile-disk 20 KhGzWhB9ZZv5ZkLSZqm6pkWx7ZF #Ubuntu 14.04
# stratus-connect-instance 2721
# update the system
apt-get update
apt-get dist-upgrade -y             # could we have an already dist-upgraded Ubuntu 14.04?
# add the following packages:
# -libfontconfig: or SAGE will crash
# -libcurl4-openssl-dev: required by sage's git; otherwise it does not recognise the https protocol
#  this might not be enough
# Using the atlas libraries from the distribution would save much compilation time; on 13.10, the package is named libatlas3-base
# I tried with libatlas3gf-base on 12.10, but it failed so far.
# texlive: that's for compiling doc-pdfwe could reduce to a subset
# texinfo: for scipy?
apt-get install libfontconfig1 libssl-dev build-essential m4 libcurl4-openssl-dev git libatlas3-base texlive-latex-recommended texlive-science texlive-lang-all texinfo

# Add the volatile disk. On this VM, its mount point is /dev/sdc
# TODO: mount automatically /mnt/volatile at each boot
yes | mkfs.ext4 /dev/sdc
mkdir /mnt/volatile
mount /dev/sdc /mnt/volatile

# Create sage user
# TODO: execute the rest of this script as Sage
useradd -p xxx -m -d /mnt/volatile/sage -s /bin/bash sage
mkdir ~sage/.ssh
chmod 700 ~sage/.ssh
cp .ssh/authorized_keys ~sage/.ssh/
chown -R sage:sage ~sage/.ssh

reboot

ssh sage@...
screen

git clone git://github.com/sagemath/sage.git
cd sage
export SAGE_ATLAS_LIB=/usr/lib/
export SAGE_ATLAS_ARCH=base
export MAKE="make -j8"
make

cat > patchbotconfig<<EOF
{
  "use_ccache": false
}
EOF
./sage -i patchbot
./sage -patchbot --ticket 15801 --config patchbotconfig 2>&1 | tee log
./sage -patchbot

# set path to SAGE binaries
#ln -s /mnt/volatile/sage-6.1.1-x86_64-Linux/sage /usr/local/bin/sage

# Done!
