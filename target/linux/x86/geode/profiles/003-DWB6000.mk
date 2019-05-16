#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/DWB6000
	NAME:=DWB6000 Profile
	VERSION:=-G115-20151224_BR1
	PACKAGES:= \
		coreutils-stty \
		-dnsmasq \
		fdisk \
		-firewall \
		-hwclock \
		-ip6tables -iptables \
		iw iwinfo \
		kmod-bridge \
		-kmod-button-hotplug \
		-kmod-ledtrig-heartbeat -kmod-ledtrig-gpio -kmod-ledtrig-netdev \
		-kmod-nf-nathelper \
		-kmod-ipt-conntrack -kmod-ipt-core \
		libiwinfo-lua \
		libncurses \
		luci-base luci-mod-admin-full luci-theme-bootstrap \
		ncat \
		-odhcpd -odhcp6c \
		-ppp -ppp-mod-pppoe \
		uhttpd uhttpd-mod-ubus \
		usbutils \
		wireless-tools \
		-wpad-mini wpad
	FILES_COPY:= \
		files/DWx6000/copy/. \
		files/DWB6000/copy/.
	FILES_REMOVE:= \
		files/DWx6000/remove.lst \
		files/DWB6000/remove.lst
	SERIAL_BAUDRATE:=115200
endef

define Profile/DWB6000/Description
	DWB6000 LAN to multi-WiFi client bridge package set based on Geode board.
endef
$(eval $(call Profile,DWB6000))
