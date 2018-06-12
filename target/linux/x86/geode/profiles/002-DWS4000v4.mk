#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/DWS4000v4
  NAME:=DWS4000v4 Profile
  VERSION:=.21
  PACKAGES:=
  FILES_COPY:=files/DWS4000v4
  FILES_REMOVE:=files/DWS4000v4/remove.lst
endef

define Profile/DWS4000v4/Description
	DWS4000v4 LAN to WiFi client bridge package set based on Geode board.
endef
$(eval $(call Profile,DWS4000v4))
