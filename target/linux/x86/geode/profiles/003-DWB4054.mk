#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/DWB4054
  NAME:=DWB4054 Profile
  PACKAGES:=avahi-nodbus-daemon
endef

define Profile/DWB4054/Description
	DWB4054 package set based on Geode board.
endef
$(eval $(call Profile,DWB4054))
