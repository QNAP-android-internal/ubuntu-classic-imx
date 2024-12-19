#!/bin/bash
# Author: Wig Cheng <onlywig@gmail.com>
# Date: 12/11/2024

DISTRO=$1

COL_GREEN="\e[1;32m"
COL_NORMAL="\e[m"

echo "${COL_GREEN}Technexion customized minimal rootfs staring...${COL_NORMAL}"
echo "${COL_GREEN}creating ubuntu sudoer account...${COL_NORMAL}"
cd /
echo wafer-imx8mp > /etc/hostname
echo -e "127.0.1.1\twafer-imx8mp" >> /etc/hosts
echo -e "nameserver\t8.8.8.8" >> /etc/hosts

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

# for teamviewer and anydesk
apt -y install libpolkit-gobject-1-0:armhf libraspberrypi0:armhf libraspberrypi-dev:armhf libraspberrypi-bin:armhf libgles-dev:armhf libegl-dev:armhf
apt -y install libegl1-mesa libgail-common libgail18 libgtk2.0-0 libgtk2.0-bin libgtk2.0-common libpango1.0-0

# X11 setting
cat <<END > /etc/X11/xorg.conf
Section "Device"
Identifier "DRM Device"
Driver "modesetting"
Option "kmsdev" "/dev/dri/card1"
EndSection
END

# audio setting
cat <<END > /home/ubuntu/.asoundrc
pcm.!default {
  type plug
  slave {
    pcm "hw:0,0"
  }
}

ctl.!default {
  type hw
  card 0
}
END

# GUI desktop support
apt -y install xfce4 fluxbox onboard xterm xfce4-screenshooter rfkill alsa-utils minicom strace
if [[ "$DISTRO" == "jammy" ]]; then
    apt -y install slim
    # auto login
    sed -i 's/#auto_login\s\+no/auto_login          yes/' /etc/slim.config
    sed -i 's/#default_user\s\+simone/default_user        ubuntu/' /etc/slim.conf
else
    apt -y install lightdm
    sed -i '/ExecStartPre=.*lightdm.*/a ExecStartPre=/bin/sh -c '\''sudo touch /run/utmp && sudo chmod 664 /run/utmp && sudo chown root:utmp /run/utmp'\''' /lib/systemd/system/lightdm.service
    sed -i '/ExecStartPre=.*lightdm.*/a ExecStartPre=/bin/sh -c '\''rm -rf /home/ubuntu/.local/share/keyrings'\''' /lib/systemd/system/lightdm.service

# auto login
cat <<END > /etc/lightdm/lightdm.conf
[SeatDefaults]
autologin-user=ubuntu
autologin-user-timeout=5
END

    rm -rf /usr/share/xsessions/fluxbox.desktop
    cp -a /usr/share/xsessions/xfce.desktop /usr/share/xsessions/ubuntu.desktop
    usermod -aG nopasswdlogin ubuntu
    sed -i 's/^-auth    optional        pam_gnome_keyring\.so/#auth    optional        pam_gnome_keyring.so/' /etc/pam.d/lightdm-greeter
    sed -i 's/^-session optional        pam_gnome_keyring\.so auto_start/#session optional        pam_gnome_keyring.so auto_start/' /etc/pam.d/lightdm-greeter
fi

# Install ubuntu-restricted-extras
echo steam steam/license note '' | sudo debconf-set-selections
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections # auto accepted eula agreements
apt -y install ttf-mscorefonts-installer
echo ubuntu-restricted-extras msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections # auto accepted eula agreements
apt -y install ubuntu-restricted-extras

apt -y remove xfce4-screensaver xscreensaver gnome-terminal
apt -y autoremove

mkdir -p /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/
chown ubuntu:ubuntu /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/
chown ubuntu:ubuntu /home/ubuntu/.config/xfce4/xfconf/
chown ubuntu:ubuntu /home/ubuntu/.config/xfce4/
chown ubuntu:ubuntu /home/ubuntu/.config/
touch /home/ubuntu/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
cat <<END > /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="empty"/>
    <property name="IconThemeName" type="empty"/>
    <property name="DoubleClickTime" type="empty"/>
    <property name="DoubleClickDistance" type="empty"/>
    <property name="DndDragThreshold" type="empty"/>
    <property name="CursorBlink" type="empty"/>
    <property name="CursorBlinkTime" type="empty"/>
    <property name="SoundThemeName" type="empty"/>
    <property name="EnableEventSounds" type="empty"/>
    <property name="EnableInputFeedbackSounds" type="empty"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI" type="empty"/>
    <property name="Antialias" type="empty"/>
    <property name="Hinting" type="empty"/>
    <property name="HintStyle" type="empty"/>
    <property name="RGBA" type="empty"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="CanChangeAccels" type="empty"/>
    <property name="ColorPalette" type="empty"/>
    <property name="FontName" type="string" value="Sans 15"/>
    <property name="MonospaceFontName" type="empty"/>
    <property name="IconSizes" type="empty"/>
    <property name="KeyThemeName" type="empty"/>
    <property name="ToolbarStyle" type="empty"/>
    <property name="ToolbarIconSize" type="empty"/>
    <property name="MenuImages" type="empty"/>
    <property name="ButtonImages" type="empty"/>
    <property name="MenuBarAccel" type="empty"/>
    <property name="CursorThemeName" type="empty"/>
    <property name="CursorThemeSize" type="empty"/>
    <property name="DecorationLayout" type="empty"/>
  </property>
</channel>
END

yes "Y" | apt install --reinstall network-manager-gnome

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
