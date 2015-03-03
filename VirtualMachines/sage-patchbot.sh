#!/bin/bash

# Author: Nicolas M. Thiéry

# Run the VM with e.g.:
# stratus-run-instance --cpu=8 --ram=4000 --swap==2000 --volatile-disk 20 --cloud-init 'ssh,$HOME/.ssh/id_rsa.pub#none,./sage-patchbot.sh' BsHnKXtlxejHFYIq1oTQvFE2sZy



### That's the interesting one:
# stratus-run-instance --vm-name sage-patchbot --cpu=8 --ram=4000 --swap==2000 --volatile-disk 20 --cloud-init "ssh,$HOME/.ssh/id_rsa.pub#x-shellscript,sage-patchbot.sh" BJILII-tFu00rKKM-enj9l83rsn #Ubuntu 14.04

# stratus-create-image -s ./sage-patchbot.sh --vm-name sage-patchbot --cpu=8 --ram=4000 --swap==2000 --volatile-disk 20 BJILII-tFu00rKKM-enj9l83rsn #Ubuntu 14.04

# stratus-connect-instance 2721
# update the system
apt-get update
apt-get dist-upgrade -y             # could we have an already dist-upgraded Ubuntu 14.04?
# add the following packages:
# -libfontconfig: or SAGE will crash
# -libcurl4-openssl-dev: required by sage's git; otherwise it does not recognise the https protocol
#  this might not be enough
# the atlas libraries save much compilation time
# texlive: that's for compiling doc-pdfwe could reduce to a subset
# texinfo: for scipy?
apt-get install -y libfontconfig1 libssl-dev build-essential m4 gfortran libcurl4-openssl-dev git libatlas3-base libatlas-base-dev texlive-latex-recommended texlive-science texlive-lang-all texinfo

# Add the volatile disk. On this VM, its mount point is /dev/vdc
# TODO: mount automatically /mnt/volatile at each boot
yes | mkfs.ext4 /dev/vdc
mkdir /mnt/volatile
cat >> /etc/fstab <<EOF
/dev/vdc /mnt/volatile ext4 errors=remount-ro 0 1
EOF
mount -a

# Sets hostname
hostname sage-patchbot.lal.in2p3.fr

# Create Sage user and prepare its directory
useradd -p xxx -m -d /mnt/volatile/sage -s /bin/bash sage
mkdir ~sage/.ssh
chmod 700 ~sage/.ssh
cp .ssh/authorized_keys ~sage/.ssh/

cat > ~sage/start-patchbot <<EOF
#!/bin/sh

export SAGE_ATLAS_LIB=/usr/lib/
export SAGE_ATLAS_ARCH=base
export MAKE="make -j8"
export TMPDIR=$HOME/tmp

if [ ! -d sage ]; then
    mkdir ~/tmp
    mkdir ~/bin
    git clone git://github.com/sagemath/sage.git
    cd sage
    git fetch origin develop:develop
    git checkout develop

    make
    ln -s ~/sage/sage ~/bin/

    cat > patchbotconfig<<EOF
    {
      "use_ccache": True,
      "base_branch": "develop",
      "bonus: {"categories": 5, "combinatorics": 5},
      "parallelism": 3,
    }
    EOF
else
    cd sage
fi
sage -i http://sage.math.washington.edu/home/robertwb/patches/patchbot-2.1.1.1.spkg
sage -patchbot

# from http://patchbot.sagemath.org/
#./sage -i patchbot
#./sage -patchbot --ticket 15801 --config patchbotconfig 2>&1 | tee log
#./sage -patchbot
EOF
chmod 700 ~sage/start-patchbot

chown -R sage:sage ~sage

# TODO: setup iptables

reboot

# Done!
