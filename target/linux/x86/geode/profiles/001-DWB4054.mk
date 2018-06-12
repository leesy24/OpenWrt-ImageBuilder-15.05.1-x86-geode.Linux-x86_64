#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/DWB4054
  NAME:=DWB4054 Profile
  VERSION:=v6.1
  PACKAGES:= \
	avahi-nodbus-daemon \
	collectd-mod-iwinfo \
	coreutils-stty \
	dosfsck dosfslabel \
	ethtool \
	fdisk \
	iperf \
	iwinfo \
	kamailio3-mod-dialog \
	kmod-fs-msdos \
	kmod-hwmon-lm90 \
	kmod-i2c-algo-pca kmod-i2c-algo-pcf kmod-i2c-gpio \
	kmod-ide-generic kmod-ide-generic-old \
	kmod-leds-gpio \
	kmod-nls-cp1250 kmod-nls-cp1251 kmod-nls-cp437 kmod-nls-cp775 \
	kmod-nls-cp850 kmod-nls-cp852 kmod-nls-cp862 kmod-nls-cp864 \
	kmod-nls-cp866 kmod-nls-cp932 kmod-nls-iso8859-1 kmod-nls-iso8859-13 \
	kmod-nls-iso8859-15 kmod-nls-iso8859-2 kmod-nls-iso8859-6 \
	kmod-nls-iso8859-8 kmod-nls-koi8r kmod-nls-utf8 \
	kmod-scsi-generic \
	kmod-stp \
	kmod-usb-core kmod-usb-hid \
	kmod-usb-ohci-pci \
	kmod-usb-serial-ark3116 kmod-usb-serial-belkin kmod-usb-serial-ch341 \
	kmod-usb-serial-cp210x kmod-usb-serial-cypress-m8 kmod-usb-serial-ftdi \
	kmod-usb-serial-garmin kmod-usb-serial-keyspan kmod-usb-serial-mct \
	kmod-usb-serial-mos7720 kmod-usb-serial-option kmod-usb-serial-oti6858 \
	kmod-usb-serial-pl2303 kmod-usb-serial-qualcomm \
	kmod-usb-serial-sierrawireless kmod-usb-serial-simple \
	kmod-usb-serial-ti-usb kmod-usb-serial-wwan \
	kmod-usb-storage-extras \
	kmod-usb-uhci \
	kmod-usb2-pci \
	kmod-usbip-client kmod-usbip-server \
	luci \
	mkdosfs \
	swconfig \
	usbreset usbutils \
	vsftpd \
	wireless-tools \
	-wpad-mini wpad
  FILES_COPY:=files/DWB4054/copy
  FILES_REMOVE:=files/DWB4054/remove.lst
endef

define Profile/DWB4054/Description
	DWB4054 package set based on Geode board.
endef
$(eval $(call Profile,DWB4054))
