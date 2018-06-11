#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/DWS5000
  NAME:=DWS5000 Profile
  PACKAGES:=avahi-nodbus-daemon
  FILES_COPY:=files/DWS5000
  FILES_REMOVE:=files/DWS5000/remove.lst
endef

define Profile/DWS5000/Description
	DWS5000 package set based on Geode board.
endef
$(eval $(call Profile,DWS5000))
