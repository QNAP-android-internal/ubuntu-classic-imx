#!/bin/bash
# Author: Wig Cheng <onlywig@gmail.com>
# Date: 12/11/2024

TOP=${PWD}

# Set DISTRO from the first argument, default to "jammy" if not provided
DISTRO=${1:-jammy}

# generate rootfs
gen_pure_rootfs() {

  ARCH=armhf
  QEMU=qemu-arm-static

  mkdir rootfs

  echo "generate ubuntu rootfs... default version: jammy LTS"
  sudo debootstrap --arch="$ARCH" --keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg --verbose --foreign $DISTRO ${TOP}/rootfs
  sudo cp /usr/bin/"$QEMU" ${TOP}/rootfs/usr/bin
  sudo LANG=C chroot ${TOP}/rootfs /debootstrap/debootstrap --second-stage

  sudo cp ${TOP}/qemu_install.sh ${TOP}/rootfs/usr/bin/
  sudo cp -rv ${TOP}/deb/ ${TOP}/rootfs/opt/
  sync

  sudo LANG=C chroot ${TOP}/rootfs /bin/bash -c "chmod a+x /usr/bin/qemu_install.sh; /usr/bin/qemu_install.sh $DISTRO"
  sync

  sudo rm -rf ${TOP}/rootfs/usr/bin/qemu_install.sh

  cd ${TOP}/rootfs
  sudo tar --exclude='./dev/*' --exclude='./lost+found' --exclude='./mnt/*' --exclude='./media/*' --exclude='./proc/*' --exclude='./run/*' --exclude='./sys/*' --exclude='./tmp/*' --numeric-owner -czpvf ../rootfs.tgz .
  cd ${TOP}
}

gen_pure_rootfs "$1"
