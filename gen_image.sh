#!/bin/bash

TOP=${PWD}

echo "target: --------------> $1"

echo "creating 6.5GiB empty image ..."
sudo dd if=/dev/zero of=test.img bs=1M count=6500

echo "created."

sudo kpartx -av test.img
loop_dev=$(losetup | grep "test.img" | awk  '{print $1}')
(echo "n"; echo "p"; echo; echo "16385"; echo "+64M"; echo "n"; echo "p"; echo; echo "147456"; echo ""; echo "a"; echo "1"; echo "w";) | sudo fdisk "$loop_dev"
sudo kpartx -d test.img
sync

sudo kpartx -av test.img
loop_dev=$(losetup | grep "test.img" | awk  '{print $1}')
mapper_dev=$(losetup | grep "test.img" | awk  '{print $1}' | awk -F/ '{print $3}')

sudo mkfs.vfat -F 32 /dev/mapper/"$mapper_dev"p1
sudo mkfs.ext4 /dev/mapper/"$mapper_dev"p2

mkdir mnt

sudo mount /dev/mapper/"$mapper_dev"p1 mnt

sudo cp -rv ./output/kernel/kernel_imx/arch/arm64/boot/Image mnt/


if [[ "$1" == "wafer-imx8mp" ]]; then
  sudo cp -rv ./output/kernel/kernel_imx/arch/arm64/boot/dts/freescale/imx8mp-b643-ppc.dtb mnt/
  sudo cp -rv ./output/kernel/kernel_imx/arch/arm64/boot/dts/freescale/overlays/imx8mp-b643-ppc-mipi-dsi-tq101aj02.dtb mnt/
  sudo cp -rv ./output/kernel/kernel_imx/arch/arm64/boot/dts/freescale/overlays/imx8mp-b643-ppc-sound-max98090.dtb mnt/
  sudo cp -rv ./output/kernel/kernel_imx/arch/arm64/boot/dts/freescale/overlays/imx8mp-b643-ppc-uart-rs422.dtb mnt/
  sudo cp -rv ./output/kernel/kernel_imx/arch/arm64/boot/dts/freescale/overlays/imx8mp-b643-ppc-uart-rs485.dtb mnt/
elif [[ "$1" == "frdm-imx93" ]]; then
  sudo cp -rv ./output/kernel/kernel_imx/arch/arm64/boot/dts/freescale/imx93-lite93-evb.dtb mnt/
  sudo cp -rv ./output/kernel/kernel_imx/arch/arm64/boot/dts/freescale/imx93-lite93-evb-*.dtbo mnt/
fi

sudo umount mnt

sudo mount /dev/mapper/"$mapper_dev"p2 mnt
cd mnt
sudo tar zxvf ../output/rootfs.tgz
cd ${TOP}
sudo cp -rv ./output/kernel/kernel_imx/modules/lib/modules/* mnt/lib/modules/

sudo umount mnt

bootloader_offset=32

if [[ "$1" == "wafer-imx8mp" ]]; then
sudo dd if=./output/u-boot/uboot-imx/imx-mkimage/iMX8M/flash.bin of="$loop_dev" bs=1k seek="$bootloader_offset" conv=fsync
elif [[ "$1" == "frdm-imx93" ]]; then
sudo dd if=./output/u-boot/uboot-imx/imx-mkimage/iMX93/flash.bin of="$loop_dev" bs=1k seek="$bootloader_offset" conv=fsync
fi

sync

rm -rf mnt

sudo kpartx -d test.img
