#!/bin/bash
# Author: Wig Cheng <onlywig@gmail.com>
# Date: 06/05/2025

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

# VPU libraries
apt -y install libgirepository1.0-dev gettext liborc-0.4-dev libasound2-dev libogg-dev libtheora-dev libvorbis-dev libbz2-dev libflac-dev libgdk-pixbuf-2.0-dev libmp3lame-dev libmpg123-dev libpulse-dev libspeex-dev libtag1-dev libbluetooth-dev libusb-1.0-0-dev libcurl4-openssl-dev libssl-dev librsvg2-dev libsbc-dev libsndfile1-dev
apt -y install libgl1-mesa-dev

# Chromium libraries
apt -y apt-get install libc++1

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

# vpu libs
cp -a imx-parser/usr/include/* /usr/include/
cp -a imx-parser/usr/lib/* /usr/lib/aarch64-linux-gnu/
cp -a imx-parser/usr/share/doc/* /usr/share/doc/


cp -a imx-vpu-hantro/usr/include/hantro_dec/ /usr/include/
cp -a imx-vpu-hantro/usr/lib/* /usr/lib/aarch64-linux-gnu/

cp -a imx-vpu-hantro-vc/usr/include/hantro_VC8000E_enc /usr/include/
cp -a imx-vpu-hantro-vc/usr/lib/* /usr/lib/aarch64-linux-gnu/

cp -a imx-vpuwrap/usr/include/* /usr/include/
cp -a imx-vpuwrap/usr/lib/* /usr/lib/aarch64-linux-gnu/

mkdir -p /usr/include/imx
cp -a kernel_headers/linux/ /usr/include/imx/

rm -rf imx-parser
rm -rf imx-vpu-hantro
rm -rf imx-vpu-hantro-vc
rm -rf imx-vpuwrap
rm -rf kernel_headers

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


# Gstreamer
git clone https://github.com/nxp-imx/gstreamer -b MM_04.09.00_2405_L6.6.y
cd gstreamer
meson setup build --prefix=/usr -Dintrospection=enabled -Ddoc=disabled -Dexamples=disabled -Ddbghelp=disabled -Dnls=enabled  -Dbash-completion=disabled -Dcheck=enabled -Dcoretracers=disabled -Dgst_debug=true -Dlibdw=disabled -Dtests=enabled -Dtools=enabled -Dtracer_hooks=true -Dlibunwind=disabled -Dc_args=-I/usr/include/imx
ninja -C build install
cd -
rm -rf gstreamer

git clone https://github.com/nxp-imx/gst-plugins-base -b MM_04.09.00_2405_L6.6.y
cd gst-plugins-base
meson setup build --prefix=/usr -Dalsa=enabled -Dcdparanoia=disabled -Dgl-graphene=disabled -Dgl-jpeg=disabled -Dopus=disabled -Dogg=enabled  -Dorc=enabled -Dpango=enabled -Dgl-png=enabled -Dqt5=disabled -Dtheora=enabled -Dtremor=disabled -Dvorbis=enabled -Dlibvisual=disabled -Dx11=disabled -Dxvideo=disabled -Dxshm=disabled -Dc_args=-I/usr/include/imx
ninja -C build install
cd -
rm -rf gst-plugins-base

git clone https://github.com/nxp-imx/gst-plugins-good -b MM_04.09.00_2405_L6.6.y
cd gst-plugins-good
meson setup build --prefix=/usr -Dexamples=disabled -Dnls=enabled -Ddoc=disabled -Daalib=disabled -Ddirectsound=disabled -Ddv=disabled -Dlibcaca=disabled -Doss=enabled -Doss4=disabled -Dosxaudio=disabled -Dosxvideo=disabled -Dshout2=disabled -Dtwolame=disabled -Dwaveform=disabled -Dasm=disabled -Dbz2=enabled -Dcairo=enabled -Ddv1394=disabled -Dflac=enabled -Dgdk-pixbuf=enabled -Dgtk3=disabled -Dv4l2-gudev=enabled -Djack=disabled -Djpeg=enabled -Dlame=enabled -Dpng=enabled -Dv4l2-libv4l2=disabled -Dmpg123=enabled -Dorc=enabled -Dpulse=enabled -Dqt5=disabled -Drpicamsrc=disabled -Dsoup=enabled -Dspeex=enabled -Dtaglib=enabled -Dv4l2=enabled -Dv4l2-probe=true -Dvpx=disabled -Dwavpack=disabled -Dximagesrc=disabled -Dximagesrc-xshm=disabled -Dximagesrc-xfixes=disabled -Dximagesrc-xdamage=disabled -Dc_args=-I/usr/include/imx-gst
ninja -C build install
cd -
rm -rf gst-plugins-good

git clone https://github.com/nxp-imx/gst-plugins-bad -b MM_04.09.00_2405_L6.6.y
cd gst-plugins-bad
meson setup build --prefix=/usr -Dintrospection=enabled -Dexamples=disabled -Dnls=enabled -Dgpl=disabled -Ddoc=disabled -Daes=enabled -Dcodecalpha=enabled -Ddecklink=enabled -Ddvb=enabled -Dfbdev=enabled -Dipcpipeline=enabled -Dshm=enabled -Dtranscode=enabled -Dandroidmedia=disabled -Dapplemedia=disabled -Dasio=disabled -Dbs2b=disabled -Dchromaprint=disabled -Dd3dvideosink=disabled -Dd3d11=disabled -Ddirectsound=disabled -Ddts=disabled -Dfdkaac=disabled -Dflite=disabled -Dgme=disabled -Dgs=disabled -Dgsm=disabled -Diqa=disabled -Dladspa=disabled -Dldac=disabled -Dlv2=disabled -Dmagicleap=disabled -Dmediafoundation=disabled -Dmicrodns=disabled -Dmpeg2enc=disabled -Dmplex=disabled -Dmusepack=disabled -Dnvcodec=disabled -Dopenexr=disabled -Dopenni2=disabled -Dopenaptx=disabled -Dopensles=disabled -Donnx=disabled -Dqroverlay=disabled -Dsoundtouch=disabled -Dspandsp=disabled -Dsvthevcenc=disabled -Dteletext=disabled -Dwasapi=disabled -Dwasapi2=disabled -Dwildmidi=disabled -Dwinks=disabled -Dwinscreencap=disabled -Dwpe=disabled -Dzxing=disabled -Daom=disabled -Dassrender=disabled -Davtp=disabled -Dbluez=enabled -Dbz2=enabled -Dclosedcaption=enabled -Dcurl=enabled -Ddash=enabled -Ddc1394=disabled -Ddirectfb=disabled -Ddtls=disabled -Dfaac=disabled -Dfaad=disabled -Dfluidsynth=disabled -Dgl=enabled -Dhls=enabled -Dkms=enabled -Dcolormanagement=disabled -Dlibde265=disabled -Dcurl-ssh2=disabled -Dmodplug=disabled -Dmsdk=disabled -Dneon=disabled -Dopenal=disabled -Dopencv=disabled -Dopenh264=disabled -Dopenjpeg=disabled -Dopenmpt=disabled -Dhls-crypto=openssl -Dopus=disabled -Dorc=enabled -Dresindvd=disabled -Drsvg=enabled -Drtmp=disabled -Dsbc=enabled -Dsctp=disabled -Dsmoothstreaming=enabled -Dsndfile=enabled -Dsrt=disabled -Dsrtp=disabled -Dtinyalsa=disabled -Dtinycompress=enabled -Dttml=enabled -Duvch264=enabled -Dv4l2codecs=disabled -Dva=disabled -Dvoaacenc=disabled -Dvoamrwbenc=disabled -Dvulkan=disabled -Dwayland=enabled -Dwebp=enabled -Dwebrtc=disabled -Dwebrtcdsp=disabled -Dx11=disabled -Dx265=disabled -Dzbar=disabled -Dc_args=-I/usr/include/imx
ninja -C build install
cd -
rm -rf gst-plugins-bad

git clone https://github.com/nxp-imx/imx-gst1.0-plugin -b MM_04.09.00_2405_L6.6.y
cd imx-gst1.0-plugin
meson setup build --prefix=/usr -Dplatform=MX8 -Dc_args=-I/usr/include/imx
ninja -C build install
cd -
rm -rf imx-gst1.0-plugin

# libjpeg installation
wget https://sourceforge.net/projects/libjpeg-turbo/files/3.0.1/libjpeg-turbo-3.0.1.tar.gz
tar zxvf libjpeg-turbo-3.0.1.tar.gz
cd libjpeg-turbo-3.0.1
mkdir -p build
cd build
cmake -D CMAKE_INSTALL_PREFIX=/usr/ ../
make
make install
cd ../
cd ../
rm -rf libjpeg-turbo-3.0.1 libjpeg-turbo-3.0.1.tar.gz

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
background-image=/etc/wallpaper.png
background-type=scale-crop
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
