#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/DWS4000
  NAME:=DWS4000 Profile
  PACKAGES:=avahi-nodbus-daemon
  FILES_COPY:=files/DWS4000
  FILES_REMOVE:=files/DWS4000/remove.lst
endef

define Profile/DWS4000/Description
	DWS4000 package set based on Geode board.
endef
$(eval $(call Profile,DWS4000))
