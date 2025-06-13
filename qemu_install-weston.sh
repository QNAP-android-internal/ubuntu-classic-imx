#!/bin/bash
# Author: Wig Cheng <onlywig@gmail.com>
# Date: 06/05/2025

set -e

PLATFORM=$1
DISTRO=$2
LANGUAGE=$3

COL_GREEN="\e[1;32m"
COL_NORMAL="\e[m"

echo "${COL_GREEN}IEI customized minimal rootfs staring...${COL_NORMAL}"
echo "${COL_GREEN}creating ubuntu sudoer account...${COL_NORMAL}"
cd /
echo $PLATFORM > /etc/hostname
echo -e "127.0.1.1\t $PLATFORM" >> /etc/hosts
echo -e "nameserver\t8.8.8.8" >> /etc/hosts
echo -e "nameserver\t8.8.4.4" >> /etc/hosts

(echo "root"; echo "root";) | passwd
(echo "ubuntu"; echo "ubuntu"; echo;) | adduser ubuntu
usermod -aG sudo ubuntu

echo "${COL_GREEN}apt-get server upgrading...${COL_NORMAL}"

touch /etc/apt/sources.list
# apt-get source adding
cat <<END > /etc/apt/sources.list
deb http://ports.ubuntu.com/ubuntu-ports/ $DISTRO main
deb http://ports.ubuntu.com/ubuntu-ports/ $DISTRO universe
deb http://ports.ubuntu.com/ubuntu-ports/ $DISTRO multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ $DISTRO-backports main
deb http://ports.ubuntu.com/ubuntu-ports/ $DISTRO-security main
END


# apt-get source update and installation
apt -y update
apt -y full-upgrade && apt -y autoclean && apt -y autoremove
apt -y install openssh-server iw wpasupplicant hostapd util-linux procps iproute2 haveged dnsmasq iptables net-tools ppp ntp ntpdate bridge-utils can-utils v4l-utils usbutils
apt -y install bash-completion ifupdown resolvconf alsa-utils gpiod cloud-utils udhcpc feh modemmanager software-properties-common bluez blueman gpiod


# GPU libraries
# install compile environment
apt -y install libudev-dev libinput-dev libxkbcommon-dev libpam0g-dev libx11-xcb-dev libxcb-xfixes0-dev libxcb-composite0-dev libxcursor-dev libxcb-shape0-dev libdbus-1-dev libdbus-glib-1-dev libsystemd-dev libpixman-1-dev libcairo2-dev libffi-dev libxml2-dev kbd libexpat1-dev autoconf automake libtool meson cmake ssh net-tools network-manager iputils-ping rsyslog bash-completion htop resolvconf dialog vim udhcpc udhcpd git v4l-utils alsa-utils git gcc less autoconf autopoint libtool bison flex gtk-doc-tools libglib2.0-dev libpango1.0-dev libatk1.0-dev kmod pciutils libjpeg-dev
apt -y install libpipewire-0.3-dev seatd libseat-dev

cp -a imx-gpu-g2d-6.4.11.p2.6-aarch64-bc7b6a2/g2d/usr/include/* /usr/include/
cp -a imx-gpu-g2d-6.4.11.p2.6-aarch64-bc7b6a2/g2d/usr/lib/* /usr/lib/aarch64-linux-gnu/
# gpu core
cp -a imx-gpu-viv-6.4.11.p2.6-aarch64-bc7b6a2/gpu-core/etc/* /etc/
cp -a imx-gpu-viv-6.4.11.p2.6-aarch64-bc7b6a2/gpu-core/usr/include/* /usr/include/
cp -a imx-gpu-viv-6.4.11.p2.6-aarch64-bc7b6a2/gpu-core/usr/lib/* /usr/lib/aarch64-linux-gnu/
mv /usr/lib/aarch64-linux-gnu/wayland/* /usr/lib/aarch64-linux-gnu/
sync
# gpu demo
cp -a imx-gpu-viv-6.4.11.p2.6-aarch64-bc7b6a2/gpu-demos/opt/* /opt/
sync
# gpu demo
cp -a imx-gpu-viv-6.4.11.p2.6-aarch64-bc7b6a2/gpu-tools/gmem-info/usr/bin/* /usr/bin/
sync

rm -rf imx-gpu-g2d-6.4.11.p2.6-aarch64-bc7b6a2
rm -rf imx-gpu-viv-6.4.11.p2.6-aarch64-bc7b6a2

# build libdrm
git clone https://github.com/nxp-imx/libdrm-imx.git
cd libdrm-imx
meson setup build --prefix=/usr -Dnouveau=enabled   -Dvmwgfx=enabled   -Domap=enabled   -Dfreedreno=enabled   -Dvc4=enabled   -Detnaviv=enabled   -Dtests=true   -Dinstall-test-programs=true   -Dexynos=disabled   -Dtegra=disabled   -Dfreedreno-kgsl=false   -Dvalgrind=disabled   -Dcairo-tests=disabled   -Dudev=false   -Dman-pages=disabled -Dvivante=true
ninja -C build install
cd -
rm -rf libdrm-imx

# build wayland
git clone https://gitlab.freedesktop.org/wayland/wayland.git
cd wayland
git checkout 1.22.0
meson setup build --prefix=/usr -Ddocumentation=false -Ddtd_validation=true
ninja -C build install
cd -
rm -rf wayland

# build wayland-protocols
git clone https://github.com/nxp-imx/wayland-protocols-imx.git
cd wayland-protocols-imx
git checkout wayland-protocols-imx-1.32
meson setup build --prefix=/usr -Dtests=false
ninja -C build install
cd -
rm -rf wayland-protocols-imx

# build weston-imx
git clone https://github.com/nxp-imx/weston-imx.git
cd weston-imx
git checkout weston-imx-12.0.4
meson setup build --prefix=/usr -Dpipewire=false  -Dsimple-clients=all -Ddemo-clients=true -Ddeprecated-color-management-colord=false -Drenderer-gl=true -Dbackend-headless=false -Dimage-jpeg=true -Drenderer-g2d=true -Dbackend-drm=true -Dlauncher-libseat=true -Dcolor-management-lcms=false -Dbackend-rdp=false -Dremoting=false -Dscreenshare=true -Dshell-desktop=true -Dshell-fullscreen=true -Dshell-ivi=true -Dshell-kiosk=true -Dsystemd=true -Ddeprecated-launcher-logind=true -Dbackend-drm-screencast-vaapi=false -Dbackend-wayland=false -Dimage-webp=false -Dbackend-x11=false -Dxwayland=false
sed -i 's/G2D_HARDWARE_PXP/G2D_HARDWARE_VG/g' ./libweston/renderer-g2d/g2d-renderer.c
ninja -C build install
cd -
rm -rf weston-imx

# weston.ini installation
mkdir -p /etc/xdg/weston/
touch /etc/xdg/weston/weston.ini
cat <<END > /etc/xdg/weston/weston.ini
[core]
#gbm-format=argb8888
use-g2d=true
repaint-window=16
idle-time=0
#xwayland=true
#enable-overlay-view=1
panel-position=none

[shell]
panel-color=0x907b6291
panel-position=bottom
cursor-theme=Adwaita
cursor-size=24

[libinput]
touchscreen_calibrator=true

#[output]
#name=HDMI-A-1
#mode=1920x1080@60
#transform=rotate-90

#[output]
#name=HDMI-A-2
#mode=off
#       WIDTHxHEIGHT    Resolution size width and height in pixels
#       off             Disables the output
#       preferred       Uses the preferred mode
#       current         Uses the current crt controller mode
#transform=rotate-90

[screen-share]
command=/usr/bin/weston --backend=rdp-backend.so --shell=fullscreen-shell.so --no-clients-resize
#start-on-startup=true
END

cat <<END > /lib/systemd/system/rc-local.service
[Unit]
Description=/etc/rc.local Compatibility
ConditionPathExists=/etc/rc.local

# Make sure we are started after logins are permitted.
Requires=systemd-user-sessions.service
After=systemd-user-sessions.service

# If Plymouth is used, we want to start when it is on its way out.
After=plymouth-quit-wait.service

# D-Bus is necessary for contacting logind. Logind is required.
Wants=dbus.socket
After=dbus.socket


[Service]
Type=simple
Environment="XDG_RUNTIME_DIR=/run/user/0"
ExecStart=/usr/bin/weston
User=root
Group=root
PAMName=weston-autologin

[Install]
WantedBy=graphical.target
END

cat <<END > /etc/rc.local
#!/bin/sh
sleep 10
export XDG_RUNTIME_DIR=/run/user/1000
weston &
export WAYLAND_DISPLAY=wayland-1
END

systemctl enable rc-local

# let network-manager handle all network interfaces
touch /etc/NetworkManager/conf.d/10-globally-managed-devices.conf
sed -i 's/managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf

# disable type password everytime using ubuntu user
sed -i 's/sudo\tALL=(ALL:ALL) ALL/sudo\tALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers

# zram swap size
echo "${COL_GREEN}Add swap partition...Default size is one-fourth of total memory${COL_NORMAL}"
apt -y install zram-config
sed -i 's/totalmem\ \/\ 2/totalmem\ \/\ 4/' /usr/bin/init-zram-swapping

mkdir -p /lib/modules/

# clear the patches
rm -rf /var/cache/apt/archives/*
sync
