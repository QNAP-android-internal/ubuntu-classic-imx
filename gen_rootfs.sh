#!/bin/bash
# Author: Wig Cheng <onlywig@gmail.com>
# Date: 12/11/2024

TOP=${PWD}

# Set PLATFORM from 1st argument, default to "frdm-imx93" if not provided
PLATFORM=${1:-frdm-imx93}

# Set DISTRO from the 2nd argument, default to "jammy" if not provided
DISTRO=${2:-jammy}
# Set LANGUAGE from the 3rd argument, default to "C" if not provided
LANGUAGE=${3:-C}

# generate rootfs
gen_pure_rootfs() {

  ARCH=arm64
  QEMU=qemu-aarch64-static

  if [ -d "rootfs" ]; then
    sudo cp /usr/bin/"$QEMU" ${TOP}/rootfs/usr/bin
  else
    mkdir rootfs
    echo "generate ubuntu rootfs... default version: jammy LTS"

    sudo debootstrap --arch="$ARCH" --keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg --verbose --foreign $DISTRO ${TOP}/rootfs
    sudo cp /usr/bin/"$QEMU" ${TOP}/rootfs/usr/bin
    sudo LANG=C chroot ${TOP}/rootfs /debootstrap/debootstrap --second-stage
  fi

  if [[ $PLATFORM == "wafer-imx8mp" ]]; then
    # vivante libraries
    sudo cp -a ${TOP}/libs_overlay/gpu_libs/imx8mp/kernel-6.6.23/imx-gpu-g2d-6.4.11.p2.6-aarch64-bc7b6a2/ ${TOP}/rootfs/
    sudo cp -a ${TOP}/libs_overlay/gpu_libs/imx8mp/kernel-6.6.23/imx-gpu-viv-6.4.11.p2.6-aarch64-bc7b6a2/ ${TOP}/rootfs/
    # vpu libraries
    sudo cp -a ${TOP}/libs_overlay/vpu_libs/imx8mp/kernel-6.6.23/imx-parser/ ${TOP}/rootfs/
    sudo cp -a ${TOP}/libs_overlay/vpu_libs/imx8mp/kernel-6.6.23/imx-vpu-hantro/ ${TOP}/rootfs/
    sudo cp -a ${TOP}/libs_overlay/vpu_libs/imx8mp/kernel-6.6.23/imx-vpu-hantro-vc/ ${TOP}/rootfs/
    sudo cp -a ${TOP}/libs_overlay/vpu_libs/imx8mp/kernel-6.6.23/imx-vpuwrap/ ${TOP}/rootfs/
    sudo cp -a ${TOP}/libs_overlay/vpu_libs/imx8mp/kernel-6.6.23/kernel_headers/ ${TOP}/rootfs/
    sync
    sudo cp -a ${TOP}/libs_overlay/wallpapers/wallpaper.png ${TOP}/rootfs/etc/
    QEMU_FILE="qemu_install-weston.sh"
  else
    QEMU_FILE="qemu_install.sh"
  fi

  sudo cp ${TOP}/${QEMU_FILE} ${TOP}/rootfs/usr/bin/
  sudo LANG=C chroot ${TOP}/rootfs /bin/bash -c "chmod a+x /usr/bin/${QEMU_FILE}; /usr/bin/${QEMU_FILE} $PLATFORM $DISTRO $LANGUAGE"
  sync
  sudo rm -rf ${TOP}/rootfs/usr/bin/${QEMU_FILE}

  cd ${TOP}/rootfs
  sudo tar --exclude='./dev/*' --exclude='./lost+found' --exclude='./mnt/*' --exclude='./media/*' --exclude='./proc/*' --exclude='./run/*' --exclude='./sys/*' --exclude='./tmp/*' --numeric-owner -czpvf ../rootfs.tgz .
  cd ${TOP}
}

gen_pure_rootfs "$1"
