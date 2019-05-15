# Makefile for OpenWrt
#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

TOPDIR:=${CURDIR}
LC_ALL:=C
LANG:=C
export TOPDIR LC_ALL LANG
export OPENWRT_VERBOSE=s
all: help

include $(TOPDIR)/include/host.mk

ifneq ($(OPENWRT_BUILD),1)
  override OPENWRT_BUILD=1
  export OPENWRT_BUILD
endif

include rules.mk
include $(INCLUDE_DIR)/debug.mk
include $(INCLUDE_DIR)/depends.mk

include $(INCLUDE_DIR)/version.mk
export REVISION

define Helptext
Available Commands:
	help:	This help text
	info:	Show a list of available target profiles
	clean:	Remove images and temporary build files
	image:	Build an image (see below for more information).

Building images:
	By default 'make image' will create an image with the default
	target profile and package set. You can use the following parameters
	to change that:

	make image PROFILE="<profilename>" # override the default target profile
	make image PACKAGES="<pkg1> [<pkg2> [<pkg3> ...]]" # include extra packages
	make image BIN_DIR="<path>" # alternative output directory for the images

endef
$(eval $(call shexport,Helptext))

help: FORCE
	echo "$$$(call shvar,Helptext)"


# override variables from rules.mk
PACKAGE_DIR:=$(TOPDIR)/packages
OPKG:= \
  IPKG_NO_SCRIPT=1 \
  IPKG_TMP="$(TMP_DIR)/ipkgtmp" \
  IPKG_INSTROOT="$(TARGET_DIR)" \
  IPKG_CONF_DIR="$(TMP_DIR)" \
  IPKG_OFFLINE_ROOT="$(TARGET_DIR)" \
  $(STAGING_DIR_HOST)/bin/opkg \
	-f $(TOPDIR)/repositories.conf \
	--force-depends \
	--force-overwrite \
	--force-postinstall \
	--cache $(DL_DIR) \
	--offline-root $(TARGET_DIR) \
	--add-dest root:/ \
	--add-arch all:100 \
	--add-arch $(ARCH_PACKAGES):200

define Profile
  $(eval $(call Profile/Default))
  $(eval $(call Profile/$(1)))
  ifeq ($(USER_PROFILE),)
    USER_PROFILE:=$(1)
  endif
  $(1)_NAME:=$(NAME)
  $(1)_VERSION:=$(VERSION)
  $(1)_PACKAGES:=$(PACKAGES)
  $(1)_FILES_COPY:=$(FILES_COPY)
  $(1)_FILES_REMOVE:=$(FILES_REMOVE)
  $(1)_SERIAL_BAUDRATE:=$(SERIAL_BAUDRATE)

  PROFILE_NAMES += $(1)
  PROFILE_LIST += \
	echo '$(1):'; [ -z '$(NAME)' ] || \
	echo '	Name: $(NAME)'; \
	echo '	Version: $(VERSION)'; \
	echo '	Packages: $(PACKAGES)'; \
	echo '	Files copy: $(FILES_COPY)'; \
	echo '	Files remove: $(FILES_REMOVE)';
ifneq ($(SERIAL_BAUDRATE),)
  PROFILE_LIST += \
	echo '	Serial baudrate: $(SERIAL_BAUDRATE)';
else
  PROFILE_LIST += \
	echo '	Serial baudrate: default';
endif
endef

include $(INCLUDE_DIR)/target.mk

_call_info: FORCE
	echo 'Current Target: "$(BOARD) $(CPU_TYPE)$(if $(SUBTARGET), ($(BOARDNAME)))"'
	echo 'Default Packages: $(DEFAULT_PACKAGES)'
	echo 'Available Profiles:'
	echo; $(PROFILE_LIST)

BUILD_VERSION:=$($(USER_PROFILE)_VERSION)
BUILD_FILES_COPY:=$($(USER_PROFILE)_FILES_COPY)
BUILD_FILES_REMOVE:=$($(USER_PROFILE)_FILES_REMOVE)

BUILD_PACKAGES:=$(sort $(DEFAULT_PACKAGES) $(USER_PACKAGES) $($(USER_PROFILE)_PACKAGES) kernel)
# "-pkgname" in the package list means remove "pkgname" from the package list
BUILD_PACKAGES:=$(filter-out $(filter -%,$(BUILD_PACKAGES)) $(patsubst -%,%,$(filter -%,$(BUILD_PACKAGES))),$(BUILD_PACKAGES))
PACKAGES:=
BUILD_SERIAL_BAUDRATE:=$($(USER_PROFILE)_SERIAL_BAUDRATE)

_call_image:
	@echo 'Building images for $(BOARD) $(CPU_TYPE)$(if $($(USER_PROFILE)_NAME), - $($(USER_PROFILE)_NAME))'
	@echo 'Version: $(BUILD_VERSION)'
	@echo 'Packages: $(BUILD_PACKAGES)'
	@echo 'Files copy: $(BUILD_FILES_COPY)'
	@echo 'Files remove: $(BUILD_FILES_REMOVE)'
ifneq ($(BUILD_SERIAL_BAUDRATE),)
	@echo 'Serial baudrate: $(BUILD_SERIAL_BAUDRATE)'
else
	@echo 'Serial baudrate: default'
endif
	@echo
	rm -rf $(TARGET_DIR)
	mkdir -p $(TARGET_DIR) $(BIN_DIR) $(TMP_DIR) $(DL_DIR)
	if [ ! -f "$(PACKAGE_DIR)/Packages" ] || [ ! -f "$(PACKAGE_DIR)/Packages.gz" ] || [ "`find $(PACKAGE_DIR) -cnewer $(PACKAGE_DIR)/Packages.gz`" ]; then \
		echo "Package list missing or not up-to-date, generating it.";\
		$(MAKE) package_index; \
	else \
		mkdir -p $(TARGET_DIR)/tmp; \
		$(OPKG) update || true; \
	fi
	$(MAKE) package_install
ifneq ($(BUILD_FILES_COPY),)
	$(MAKE) copy_files
endif
	$(MAKE) package_postinst
ifneq ($(BUILD_FILES_REMOVE),)
ifneq ($(wildcard $(BUILD_FILES_REMOVE)),)
	@echo
	@echo Remove useless files
	@for remove_files in $(BUILD_FILES_REMOVE); do \
		echo "remove_files $$remove_files"; \
		while IFS='' read -r filename; do \
			[ -z "$$filename" ] && continue; \
			echo -e "\tRemoving \"$$filename\""; \
			rm -rfv "$(TARGET_DIR)$$filename"; \
		done < <(tr -d '[:blank:]\r' < $$remove_files); \
	done;
endif
endif
	$(MAKE) build_image

package_index: FORCE
	@echo
	@echo Building package index...
	@mkdir -p $(TMP_DIR) $(TARGET_DIR)/tmp
	(cd $(PACKAGE_DIR); $(SCRIPT_DIR)/ipkg-make-index.sh . > Packages && \
		gzip -9c Packages > Packages.gz \
	) >/dev/null 2>/dev/null
	$(OPKG) update || true

package_install: FORCE
	@echo
	@echo Installing packages...
	$(OPKG) install $(firstword $(wildcard $(PACKAGE_DIR)/libc_*.ipk $(PACKAGE_DIR)/base/libc_*.ipk))
	$(OPKG) install $(firstword $(wildcard $(PACKAGE_DIR)/kernel_*.ipk $(PACKAGE_DIR)/base/kernel_*.ipk))
	$(OPKG) install $(BUILD_PACKAGES)
	rm -f $(TARGET_DIR)/usr/lib/opkg/lists/*

copy_files: FORCE
	@echo
	@echo 'Copying extra files$(if $($(USER_PROFILE)_FILES_COPY), of profile $(USER_PROFILE))'
	@$(call file_copy,$($(USER_PROFILE)_FILES_COPY),$(TARGET_DIR)/)

package_postinst: FORCE
	@echo
	@echo Cleaning up
	@rm -f $(TARGET_DIR)/tmp/opkg.lock
	@echo
	@echo Activating init scripts
	@mkdir -p $(TARGET_DIR)/etc/rc.d
	@( \
		cd $(TARGET_DIR); \
		for script in ./usr/lib/opkg/info/*.postinst; do \
			IPKG_INSTROOT=$(TARGET_DIR) $$(which bash) $$script; \
		done || true \
	)
	rm -f $(TARGET_DIR)/usr/lib/opkg/info/*.postinst
	$(if $(CONFIG_CLEAN_IPKG),rm -rf $(TARGET_DIR)/usr/lib/opkg)

build_image: FORCE
	@echo
	@echo Building images...
	$(NO_TRACE_MAKE) -C target/linux/$(BOARD)/image install TARGET_BUILD=1 IB=1 \
		$(if $(USER_PROFILE),PROFILE="$(USER_PROFILE)") \
		VERSION="$(BUILD_VERSION)" \
		SERIAL_BAUDRATE="$(BUILD_SERIAL_BAUDRATE)"

clean:
	rm -rf $(TMP_DIR) $(DL_DIR) $(TARGET_DIR) $(BIN_DIR)


info:
	(unset PROFILE PACKAGES MAKEFLAGS; $(MAKE) -s _call_info)

image:
ifneq ($(PROFILE),)
  ifeq ($(filter $(PROFILE),$(PROFILE_NAMES)),)
	@echo 'Profile "$(PROFILE)" does not exist!'
	@echo 'Use "make info" to get a list of available profile names.'
	@exit 1
  endif
endif
	(unset PROFILE PACKAGES MAKEFLAGS; \
	$(MAKE) _call_image \
		$(if $(PROFILE),USER_PROFILE="$(PROFILE)") \
		$(if $(PACKAGES),USER_PACKAGES="$(PACKAGES)") \
		$(if $(BIN_DIR),BIN_DIR="$(BIN_DIR)"))

.SILENT: help info image

