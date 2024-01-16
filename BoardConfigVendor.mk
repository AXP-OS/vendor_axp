##############################################################################
#
# This file is part of AXP.OS (https://axp.binbash.rocks)
# LICENSE: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.txt)
#
# Copyright (C) 2023 steadfasterX <steadfasterX -AT- gmail #DOT# com>
# Copyright (C) 2024 steadfasterX <steadfasterX -AT- gmail #DOT# com>
#
##############################################################################
# AXP.OS advanced AVB handling
#
# verification:
# $> out/host/linux-x86/bin/avbtool info_image --image vbmeta.img
# $> out/host/linux-x86/bin/avbtool verify_image --image vbmeta.img
##############################################################################

# Enable android verified boot
BOARD_AVB_ENABLE := true
# AVB key size and hash
BOARD_AVB_ALGORITHM := SHA512_RSA4096

# pub key (avb_pkmd.bin) must be flashed to avb_custom_key partition
# see https://github.com/AXP-OS/build/wiki/Bootloader-Lock
BOARD_AVB_KEY_PATH := user-keys/avb.pem

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

# enable for troublehshooting vbmeta digest:
# (do not set on productive builds)
#BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flag 2

# Using sha512 for the hashtree of all partitions
TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM := sha512

# overwrite general hashtree algorithms
TARGET_AVB_SYSTEM_HASHTREE_ALGORITHM := $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
TARGET_AVB_SYSTEM_OTHER_HASHTREE_ALGORITHM := $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
TARGET_AVB_PRODUCT_HASHTREE_ALGORITHM := $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
TARGET_AVB_SYSTEM_EXT_HASHTREE_ALGORITHM := $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
TARGET_AVB_SYSTEM_DLKM_HASHTREE_ALGORITHM := $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)

# enforce global hashtree algorithm for boot, dtbo, system, system_other|ext|dlkm, product
BOARD_AVB_BOOT_ADD_HASH_FOOTER_ARGS += --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
BOARD_AVB_DTBO_ADD_HASH_FOOTER_ARGS += --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
BOARD_AVB_SYSTEM_OTHER_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
BOARD_AVB_SYSTEM_EXT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
BOARD_AVB_SYSTEM_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
BOARD_AVB_PRODUCT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
# enforce global hashtree algorithm for vendor, odm
BOARD_AVB_VENDOR_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
BOARD_AVB_ODM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
# enforce global hashtree algorithm for vendor_dlkm , odm_dlkm
BOARD_AVB_VENDOR_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)
BOARD_AVB_ODM_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm $(TARGET_AVB_GLOBAL_HASHTREE_ALGORITHM)