#!/bin/bash

# Author: Julien Leroy

# Run the VM with:
# stratus-run-instance -type=m1.small --volatile-disk 20 --cloud-init 'ssh,$HOME/.ssh/id_rsa.pub#none,./initSage.sh' BsHnKXtlxejHFYIq1oTQvFE2sZy
# update the system
apt-get update
apt-get dist-upgrade -y
# add the following packages:
# -libfontconfig or SAGE will crash
# -git, libssl, make, m4 to allow SAGE to upgrade (neutralized for now)
apt-get install libfontconfig1 -y
# apt-get install git libssl0.9.8 make m4 dpkg-dev -y

# Add the volatile disk. On this VM, its mount point is /dev/sdc
yes | mkfs.ext4 /dev/sdc
mkdir /mnt/volatile
mount /dev/sdc /mnt/volatile

# download the current version of SAGE for ubuntu and untar it in the volatile folder
cd /mnt/volatile
wget http://www-ftp.lip6.fr/pub/math/sagemath/linux/64bit/sage-6.1.1-x86_64-Linux-Ubuntu_8.04_x86_64.tar.gz
tar zxf sage-6.1.1-x86_64-Linux-Ubuntu_8.04_x86_64.tar.gz
rm sage-6.1.1-x86_64-Linux-Ubuntu_8.04_x86_64.tar.gz
cd sage-6.1.1-x86_64-Linux/

# set path to SAGE binaries
ln -s /mnt/volatile/sage-6.1.1-x86_64-Linux/sage /usr/local/bin/sage
# upgrade SAGE. If all the libs are not there, it will only update SAGE paths, which is already very good.
sage -upgrade

# Done!
