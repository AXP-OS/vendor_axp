#########################################################################################################
#
# This file is part of AXP.OS (https://axpos.org)
# LICENSE: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.txt)
#
# Copyright (C) 2023-2026 steadfasterX <steadfasterX -AT- gmail #DOT# com>
#
#########################################################################################################
# AXP.OS common overrides and configs
#
# AVB 1 verification:
# $> mka generate_verity_key
# $> boot_signer -verify boot.img | recovery.img
# $> verity_verifier vendor.img -mincrypt user-keys/verity_key
#
# AVB 2 verification:
# $> external/avb/avbtool info_image --image vbmeta.img
# $> external/avb/avbtool verify_image --follow_chain_partitions --image vbmeta.img
#########################################################################################################
#
# !!!!!!!! IMPORTANT !!!!!!!!!!
#
# in order to make use of the required conditions this BoardConfig must be explicitly
# included in the target's own BoardConfig.mk - at the bottom (must be the last line)!
# Here a copy template for the device tree:
#
# # even though we include vendor/axp/config/common.mk we need to include BoardConfig (after the above
# # definitions & includes), too so we we can make use of the conditions within
# include vendor/axp/BoardConfigVendor.mk
#
#########################################################################################################

# override vendor security patch date if set in vendor_firmware
ifdef VENDOR_SECPATCH_DATE
VENDOR_SECURITY_PATCH := $(VENDOR_SECPATCH_DATE)
endif

#########################################################################################################
# note:
# if AXP_ENABLE_AVB is true, AXP_AVB_VERSION has to be defined and accepts: 1|2
ifeq ($(AXP_ENABLE_AVB),true)

# do we want AVB 1 or 2?
ifeq ($(strip $(AXP_AVB_VERSION)),1)
$(warning AXP.OS: Using AVB v1 handling!)

# disable AVB >= 2 handling
BOARD_AVB_ENABLE := false
AXP_ENABLE_AVB_HANDLING := false

else ifeq ($(strip $(AXP_AVB_VERSION)),2) # AXP_AVB_VERSION
$(warning AXP.OS: Using AVB v2 handling!)

# enable AVB 2 handling
BOARD_AVB_ENABLE := true
AXP_ENABLE_AVB_HANDLING := true

else # AXP_AVB_VERSION
$(error missing AXP_AVB_VERSION environment variable! Must be set to either 1 or 2 when "AXP_ENABLE_AVB := true".)

endif # AXP_AVB_VERSION

#########################################################################################################
# load the AXP.OS advanced AVB handling - if not explictly denied
# i.e. the following configurations will be applied (if conditions within match)
# if AXP_ENABLE_AVB_HANDLING is false the defaults will be applied (if AXP_ENABLE_AVB != false)
ifneq ($(AXP_ENABLE_AVB_HANDLING), false)

$(warning AXP.OS: Using AVB - ADVANCED handling!)

# AVB key size and hash
ifdef AXP_AVB_ALGORITHM
BOARD_AVB_ALGORITHM := $(AXP_AVB_ALGORITHM)
else
BOARD_AVB_ALGORITHM := SHA512_RSA4096
endif # AXP_AVB_ALGORITHM

# pub key (avb_pkmd.bin) must be flashed to avb_custom_key partition
# !!! must match BOARD_AVB_ALGORITHM !!!
# see https://axpos.org/Bootloader-Lock
BOARD_AVB_KEY_PATH := user-keys/avb.pem

# overwrite testkeys if set
ifdef BOARD_AVB_VBMETA_SYSTEM_KEY_PATH
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := $(BOARD_AVB_KEY_PATH)
endif

ifdef BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
endif

# BOARD_AVB_RECOVERY_KEY_PATH must be defined for if non-A/B is supported. e.g. klte
# See https://android.googlesource.com/platform/external/avb/+/master/README.md#booting-into-recovery
ifneq ($(filter klte,$(BDEVICE)),)
BOARD_AVB_RECOVERY_KEY_PATH := $(BOARD_AVB_KEY_PATH)
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
ifndef BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1
endif # BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION 
endif # filter

# overwrite testkeys on partitions if defined (e.g. FP3)
ifdef BOARD_AVB_BOOT_KEY_PATH
BOARD_AVB_BOOT_KEY_PATH := $(BOARD_AVB_KEY_PATH)
endif

ifdef BOARD_AVB_SYSTEM_KEY_PATH
BOARD_AVB_SYSTEM_KEY_PATH := $(BOARD_AVB_KEY_PATH)
endif

ifdef BOARD_AVB_VENDOR_KEY_PATH
BOARD_AVB_VENDOR_KEY_PATH := $(BOARD_AVB_KEY_PATH)
endif

# overwrite testkeys on init_boot partition if defined (e.g. gs201)
ifdef BOARD_AVB_INIT_BOOT_KEY_PATH
BOARD_AVB_INIT_BOOT_KEY_PATH := $(BOARD_AVB_KEY_PATH)
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
endif

# board algorithms
BOARD_AVB_BOOT_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_RECOVERY_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_SYSTEM_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_VBMETA_VENDOR_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_VENDOR_BOOT_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_VENDOR_DLKM_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_DTBO_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_INIT_BOOT_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_ODM_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_ODM_DLKM_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_PRODUCT_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_PVMFW_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_SYSTEM_DLKM_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_SYSTEM_EXT_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_SYSTEM_OTHER_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_VENDOR_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_VENDOR_KERNEL_BOOT_ALGORITHM := $(BOARD_AVB_ALGORITHM)
CUSTOM_IMAGE_AVB_ALGORITHM := $(BOARD_AVB_ALGORITHM)

# enable for troubleshooting vbmeta digest:
# (do not set on productive builds)
#BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --set_hashtree_disabled_flag
#BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flag 2

##############################
# hashtree algorithm handling

# Treat empty or "default" the same:
ifeq ($(strip $(AXP_HASHTREE_ALGORITHM)),)
# empty
AXP_HASHTREE_ALGORITHM_DEFAULT := 1
else ifeq ($(AXP_HASHTREE_ALGORITHM),default)
# explicitly set to default
AXP_HASHTREE_ALGORITHM_DEFAULT := 1
endif # AXP_HASHTREE_ALGORITHM

ifdef AXP_HASHTREE_ALGORITHM_DEFAULT

# if AXP_HASHTREE_ALGORITHM is unset
# use either sha256 or sha512 for the hashtree of all partitions depending on the device performance
ifdef AXP_LOWEND_DEVICE
TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM := sha256
else
TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM := sha512
endif # AXP_LOWEND_DEVICE

else
# custom algorithm provided
TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM := $(AXP_HASHTREE_ALGORITHM)
endif # AXP_HASHTREE_ALGORITHM_DEFAULT

# END: hashtree algorithm handling
###################################

# overwrite general hashtree algorithms
TARGET_AVB_SYSTEM_HASHTREE_ALGORITHM := $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
TARGET_AVB_SYSTEM_OTHER_HASHTREE_ALGORITHM := $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
TARGET_AVB_SYSTEM_EXT_HASHTREE_ALGORITHM := $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
TARGET_AVB_SYSTEM_DLKM_HASHTREE_ALGORITHM := $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)

# strip any existing hash_algorithm arguments
define strip_hash_algorithm
$(shell echo $(1) | sed -E 's/--hash_algorithm sha[1-9]+//g')
endef
#set_axp_algo = $(strip $(filter-out --hash_algorithm sha1 --hash_algorithm sha256 --hash_algorithm sha512,$(1))) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
#BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS := $(call set_axp_algo,$(BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS))

# enforce global hashtree footer algorithm for system
BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS := $(call strip_hash_algorithm,$(BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS)) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)

# if required, enforce global hash footer algorithm for vendor_boot
ifdef BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE
BOARD_AVB_VENDOR_BOOT_ADD_HASH_FOOTER_ARGS := $(call strip_hash_algorithm,$(BOARD_AVB_VENDOR_BOOT_ADD_HASH_FOOTER_ARGS)) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
endif

# if required, enforce global hash footer algorithm for init_boot
ifdef BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE
BOARD_AVB_INIT_BOOT_ADD_HASH_FOOTER_ARGS := $(call strip_hash_algorithm,$(BOARD_AVB_INIT_BOOT_ADD_HASH_FOOTER_ARGS)) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
endif

# if required, enforce global hash footer algorithm for vendor_kernel
ifdef BOARD_VENDOR_KERNEL_BOOTIMAGE_PARTITION_SIZE
BOARD_AVB_VENDOR_KERNEL_BOOT_ADD_HASH_FOOTER_ARGS := $(call strip_hash_algorithm,$(BOARD_AVB_VENDOR_KERNEL_BOOT_ADD_HASH_FOOTER_ARGS)) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
endif

# if required, enforce global hash footer algorithm for pvmfw
ifdef BOARD_PVMFWIMAGE_PARTITION_SIZE
BOARD_AVB_PVMFW_ADD_HASH_FOOTER_ARGS := $(call strip_hash_algorithm,$(BOARD_AVB_PVMFW_ADD_HASH_FOOTER_ARGS)) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
endif

# FP3 breaks when adding hashtree footers (at least on boot + dtbo) so filter it out when detected
# likely it could be enabled on the other partitions but this wasn't tested
ifeq ($(filter FP3,$(BDEVICE)),) # <-- likely we need to identify the root cause for this, i.e. e.g. "if chaining"?

# enforce global hashtree algorithm for boot, dtbo, recovery, system, system_other|ext|dlkm, product
BOARD_AVB_BOOT_ADD_HASH_FOOTER_ARGS := $(call strip_hash_algorithm,$(BOARD_AVB_BOOT_ADD_HASH_FOOTER_ARGS)) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
BOARD_AVB_DTBO_ADD_HASH_FOOTER_ARGS := $(call strip_hash_algorithm,$(BOARD_AVB_DTBO_ADD_HASH_FOOTER_ARGS)) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)

# enforce global hashtree algorithm for recovery but only when there is a dedicated recovery
ifneq ($(TARGET_NO_RECOVERY),true)
BOARD_AVB_RECOVERY_ADD_HASH_FOOTER_ARGS := $(call strip_hash_algorithm,$(BOARD_AVB_RECOVERY_ADD_HASH_FOOTER_ARGS)) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
endif

BOARD_AVB_SYSTEM_OTHER_ADD_HASHTREE_FOOTER_ARGS := $(call strip_hash_algorithm,$(BOARD_AVB_SYSTEM_OTHER_ADD_HASHTREE_FOOTER_ARGS)) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
BOARD_AVB_SYSTEM_EXT_ADD_HASHTREE_FOOTER_ARGS := $(call strip_hash_algorithm,$(BOARD_AVB_SYSTEM_EXT_ADD_HASHTREE_FOOTER_ARGS)) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
BOARD_AVB_SYSTEM_DLKM_ADD_HASHTREE_FOOTER_ARGS := $(call strip_hash_algorithm,$(BOARD_AVB_SYSTEM_DLKM_ADD_HASHTREE_FOOTER_ARGS)) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
BOARD_AVB_PRODUCT_ADD_HASHTREE_FOOTER_ARGS := $(call strip_hash_algorithm,$(BOARD_AVB_PRODUCT_ADD_HASHTREE_FOOTER_ARGS)) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)

# enforce global hashtree algorithm for vendor, odm
BOARD_AVB_ODM_ADD_HASHTREE_FOOTER_ARGS := $(call strip_hash_algorithm,$(BOARD_AVB_ODM_ADD_HASHTREE_FOOTER_ARGS)) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
BOARD_AVB_VENDOR_ADD_HASHTREE_FOOTER_ARGS := $(call strip_hash_algorithm,$(BOARD_AVB_VENDOR_ADD_HASHTREE_FOOTER_ARGS)) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)

# enforce global hashtree algorithm for vendor_dlkm , odm_dlkm
BOARD_AVB_ODM_DLKM_ADD_HASHTREE_FOOTER_ARGS := $(call strip_hash_algorithm,$(BOARD_AVB_ODM_DLKM_ADD_HASHTREE_FOOTER_ARGS)) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
BOARD_AVB_VENDOR_DLKM_ADD_HASHTREE_FOOTER_ARGS := $(call strip_hash_algorithm,$(BOARD_AVB_VENDOR_DLKM_ADD_HASHTREE_FOOTER_ARGS)) --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
endif # ifeq filter FP3

endif # AXP_ENABLE_AVB_HANDLING

else # AXP_ENABLE_AVB

$(warning AXP.OS: SKIPPED AVB handling!)

endif # AXP_ENABLE_AVB
