#!/bin/bash

######################################################################
#
# v2017-11-28
#
# known issues:
#

#bridge#


######################################################################
echo -e "\e[32msetup variables\e[0m";
SRC_MOUNT=/home/pi/RetroPie/Osses


######################################################################
## optional
grep mod_install_server /etc/fstab > /dev/null || ( \
echo -e "\e[32madd usb-stick to fstab\e[0m";
[ -d "$SRC_MOUNT/" ] || sudo mkdir -p $SRC_MOUNT;
sudo sh -c "echo '
## mod_install_server
LABEL=PXE-Server  $SRC_MOUNT  auto  noatime,nofail,auto,x-systemd.automount,x-systemd.device-timeout=5,x-systemd.mount-timeout=5  0  0
' >> /etc/fstab"
sudo mount -a;
)


######################################################################
grep -q max_loop /boot/cmdline.txt 2> /dev/null || {
	echo -e "\e[32msetup cmdline.txt for more loop devices\e[0m";
	sudo sed -i '1 s/$/ max_loop=64/' /boot/cmdline.txt;
}


######################################################################
grep -q net.ifnames /boot/cmdline.txt 2> /dev/null || {
	echo -e "\e[32msetup cmdline.txt for old style network interface names\e[0m";
	sudo sed -i '1 s/$/ net.ifnames=0/' /boot/cmdline.txt;
}


######################################################################
sudo sync \
&& echo -e "\e[32mupdate...\e[0m" && sudo apt-get -y update \
&& echo -e "\e[32mupgrade...\e[0m" && sudo apt-get -y upgrade \
&& echo -e "\e[32mautoremove...\e[0m" && sudo apt-get -y --purge autoremove \
&& echo -e "\e[32mautoclean...\e[0m" && sudo apt-get autoclean \
&& echo -e "\e[32mDone.\e[0m" \
&& sudo sync


######################################################################
echo -e "\e[32minstall nfs-kernel-server for pxe\e[0m";
sudo apt-get -y install nfs-kernel-server;
sudo systemctl enable nfs-kernel-server.service;
sudo systemctl restart nfs-kernel-server.service;

######################################################################
echo -e "\e[32menable port mapping\e[0m";
sudo systemctl enable rpcbind.service;
sudo systemctl restart rpcbind.service;


######################################################################
echo -e "\e[32minstall dnsmasq for pxe\e[0m";
sudo apt-get -y install dnsmasq
sudo systemctl enable dnsmasq.service;
sudo systemctl restart dnsmasq.service;


######################################################################
echo -e "\e[32minstall samba\e[0m";
sudo apt-get -y install samba;


######################################################################
echo -e "\e[32minstall rsync\e[0m";
sudo apt-get -y install rsync;


######################################################################
echo -e "\e[32minstall syslinux-common for pxe\e[0m";
sudo apt-get -y install pxelinux syslinux-common;


######################################################################
#bridge#echo -e "\e[32minstall network bridge\e[0m";
#bridge#sudo apt-get -y install bridge-utils hostapd dnsmasq iptables iptables-persistent


######################################################################
## optional
#bridge#echo -e "\e[32minstall wireshark\e[0m";
#bridge#sudo apt-get -y install wireshark
#bridge#sudo usermod -a -G wireshark $USER


######################################################################
sync
echo -e "\e[32mDone.\e[0m";
echo -e "\e[1;31mPlease reboot\e[0m";