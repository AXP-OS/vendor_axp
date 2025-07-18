#!/bin/bash
###############################################################################
#
# This file is part of AXP.OS (https://axpos.org)
# LICENSE: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.txt)
#
# Copyright (C) 2023-2025 steadfasterX <steadfasterX -AT- binbash #DOT# com>
#
###############################################################################

# be strict on failures
#set -e

CPWD=$PWD
# get build vars (requires a lunch before!)
export AXP_TARGET_VERSION=$(build/soong/soong_ui.bash --dumpvar-mode PLATFORM_VERSION  2>/dev/null)
export AXP_TARGET_ARCH=$(build/soong/soong_ui.bash --dumpvar-mode TARGET_ARCH  2>/dev/null)
export AXP_KERNEL_PATH=$(build/soong/soong_ui.bash --dumpvar-mode TARGET_KERNEL_SOURCE  2>/dev/null)
export AXP_KERNEL_CONF=$(build/soong/soong_ui.bash --dumpvar-mode TARGET_KERNEL_CONFIG  2>/dev/null)

echo "AXP_TARGET_VERSION: $AXP_TARGET_VERSION"
echo "AXP_TARGET_ARCH: $AXP_TARGET_ARCH"
echo "AXP_KERNEL_PATH: $AXP_KERNEL_PATH"
echo "AXP_KERNEL_CONF: $AXP_KERNEL_CONF"
echo "AOS_BRANDING_BUILDTYPE: $AOS_BRANDING_BUILDTYPE"
if [ "$AOS_BRANDING_BUILDTYPE" != "SLIM" ];then AXP_LOW_STORAGE=yes ;fi # Pro includes big apps like MicroG so we do not want to reserve disk space
echo "AXP_LOW_STORAGE: $AXP_LOW_STORAGE"
echo device/${AXP_DEVICEVENDOR}/${AXP_DEVICE}

if [ "x$AXP_KERNEL_PATH" == x ];then
    echo "[AXP] ERROR: kernel path could not be detected"
else
    echo "[AXP] started with kernel path: $AXP_KERNEL_PATH"
fi

# allow a custom OTA server URI, use default if unspecified
if [ -z "$CUSTOM_AXP_OTA_SERVER_URI" ];then
    if [ "$AOS_BRANDING_BUILDTYPE" == "SLIM" ];then
        export AXP_OTA_SERVER_URI="https://$DOS_OTA_SERVER_PRIMARY/axp-slim/a${AXP_TARGET_VERSION}/api/v1/{device}/{incr}"
    else
        export AXP_OTA_SERVER_URI="https://$DOS_OTA_SERVER_PRIMARY/axp/a${AXP_TARGET_VERSION}/api/v1/{device}/{incr}"
    fi
else
    export AXP_OTA_SERVER_URI=$CUSTOM_AXP_OTA_SERVER_URI
fi
cd vendor/axp/overlays/packages/apps/Updater/app/src/main/res/values/ && git checkout strings.xml
cd $CPWD
sed -i "s|%%AXP_OTA_SERVER_URI%%|${AXP_OTA_SERVER_URI}|g" vendor/axp/overlays/packages/apps/Updater/app/src/main/res/values/strings.xml && echo "[AXP] .. updated OTA AXP_OTA_SERVER_URI"
sed -i "s|%%DOS_OTA_SERVER_PRIMARY_NAME%%|${DOS_OTA_SERVER_PRIMARY_NAME}|g" vendor/axp/overlays/packages/apps/Updater/app/src/main/res/values/strings.xml && echo "[AXP] .. updated OTA DOS_OTA_SERVER_PRIMARY_NAME"
sed -i "s|%%DOS_OTA_SERVER_SECONDARY_NAME%%|${DOS_OTA_SERVER_SECONDARY_NAME}|g" vendor/axp/overlays/packages/apps/Updater/app/src/main/res/values/strings.xml && echo "[AXP] .. updated OTA DOS_OTA_SERVER_SECONDARY_NAME"
sed -i "s|%%DOS_OTA_SERVER_ONION_PRIMARY_NAME%%|${DOS_OTA_SERVER_ONION_PRIMARY_NAME}|g" vendor/axp/overlays/packages/apps/Updater/app/src/main/res/values/strings.xml && echo "[AXP] .. updated OTA DOS_OTA_SERVER_ONION_PRIMARY_NAME"
sed -i "s|%%DOS_OTA_SERVER_ONION_SECONDARY_NAME%%|${DOS_OTA_SERVER_ONION_SECONDARY_NAME}|g" vendor/axp/overlays/packages/apps/Updater/app/src/main/res/values/strings.xml && echo "[AXP] .. updated OTA DOS_OTA_SERVER_ONION_SECONDARY_NAME"

# patch kernel source to build wireguard module
# (see: https://www.wireguard.com/compilation/#building-directly-in-tree)
if [ ! -f "$AXP_KERNEL_PATH/.wg.patched" ];then
    cd $AXP_KERNEL_PATH
    if [ -d "net/wireguard" ];then rm -rf net/wireguard ;fi
    mkdir -p net/wireguard/compat
    if [ -f $CPWD/kernel/wireguard-linux-compat/kernel-tree-scripts/create-patch.sh ];then
        $CPWD/kernel/wireguard-linux-compat/kernel-tree-scripts/create-patch.sh | patch -p1 --no-backup-if-mismatch
        git add -A && git commit --author="Jason A. Donenfeld <Jason@zx2c4.com>" -m "apply wireguard-linux-compat"
        echo "[AXP] .. patched kernel sources for wireguard"
    else
        echo "[AXP] ERROR patching kernel sources for wireguard (missing compat patcher)!"
        exit 3
    fi
    cd $CPWD
    touch $AXP_KERNEL_PATH/.wg.patched
else
    echo "[AXP] .. kernel is already patched for wireguard (patch indicator exists)"
fi

# patch kernel defconfig
if [ ! -f "$AXP_KERNEL_PATH/.defconf.patched" ];then
    for cf in $AXP_DEFCONFIG_GLOBALS; do
       grep -q "^$cf=y" $AXP_KERNEL_PATH/arch/$AXP_TARGET_ARCH/configs/$AXP_KERNEL_CONF || echo -e "\n$cf=y" >> $AXP_KERNEL_PATH/arch/$AXP_TARGET_ARCH/configs/$AXP_KERNEL_CONF
       cd $AXP_KERNEL_PATH
       git add -A && git commit --author="${AXP_GIT_AUTHOR} <${AXP_GIT_MAIL}>" -m "defconfig: applied: $cf"
       echo "[AXP] .. kernel globals defconfig $cf has been set"
       cd $CPWD
    done
    for cfd in $AXP_DEFCONFIG_DEVICE; do
       grep -q "^$cfd" $AXP_KERNEL_PATH/arch/$AXP_TARGET_ARCH/configs/$AXP_KERNEL_CONF || echo -e "\n$cfd" >> $AXP_KERNEL_PATH/arch/$AXP_TARGET_ARCH/configs/$AXP_KERNEL_CONF
       cd $AXP_KERNEL_PATH
       git add -A && git commit --author="${AXP_GIT_AUTHOR} <${AXP_GIT_MAIL}>" -m "defconfig: applied $cfd"
       echo "[AXP] .. kernel device specific defconfig $cfd has been set"
       cd $CPWD
    done
    touch $AXP_KERNEL_PATH/.defconf.patched
else
    echo "[AXP] .. kernel defconfig is already patched (patch indicator exists)"
fi

# OpenEUICC handling
if [ "$AXP_BUILD_OPENEUICC" == "true" ];then
    # handle OpenEUICC incl submodules (sync-s within the manifest does not work sometimes!)
    echo "[AXP] .. initiating OpenEUICC submodules"
    cd packages/apps/OpenEUICC
    git submodule update --init && echo "[AXP] .. OpenEUICC submodules initiated successfully"
    cd $CPWD
    # FIXME: do not apply the hacky-fix by divest (as that is included in axp's fork)! -> Scripts/LineageOS-XXX/Patch.sh
else
    echo "[AXP] .. skip building OpenEUICC (set AXP_BUILD_OPENEUICC=true in divested.vars.DEVICE to build it)"
    sed -i -E 's/^PRODUCT_PACKAGES.*OpenEUICC/# openeuicc disabled by AXP.OS/g' vendor/divested/packages.mk
    [ -d packages/apps/OpenEUICC ] && rm -rf packages/apps/OpenEUICC && echo "[AXP] .. removed packages/apps/OpenEUICC (stops divest patching)"
fi

# fixup divest deblob leftovers
if [ -f device/google/gs201/widevine/device.mk ];then
    head -n1 device/google/gs201/widevine/device.mk | grep -q PRODUCT_PACKAGES || sed -i '1i\
PRODUCT_PACKAGES += \\' device/google/gs201/widevine/device.mk
    cd device/google/gs201
    git add -A && git commit --author="${AXP_GIT_AUTHOR} <${AXP_GIT_MAIL}>" -m "gs201: fix divest deblob leftovers"
    cd $CPWD
fi

# FIXME: still needed??
if [ "$AXP_DEVICE" == "FP4" ];then
    echo "[AXP] ... specific FP4 adjustments"
    grep -q BOARD_AVB_VBMETA_SYSTEM device/${AXP_DEVICEVENDOR}/${AXP_DEVICE}/BoardConfig.mk \
        || echo "BOARD_AVB_VBMETA_SYSTEM := system" >> device/${AXP_DEVICEVENDOR}/${AXP_DEVICE}/BoardConfig.mk
fi

# free-up reserved space (required for microG etc)
if [ "$AXP_LOW_STORAGE" == "yes" ];then
    echo "[AXP] ... free-up reserved space"
    BOARDRESERVATION="BOARD_PRODUCTIMAGE_EXTFS_INODE_COUNT BOARD_PRODUCTIMAGE_PARTITION_RESERVED_SIZE BOARD_SYSTEMIMAGE_EXTFS_INODE_COUNT BOARD_SYSTEMIMAGE_PARTITION_RESERVED_SIZE BOARD_SYSTEM_EXTIMAGE_EXTFS_INODE_COUNT BOARD_SYSTEM_EXTIMAGE_PARTITION_RESERVED_SIZE"

    for bmk in $(find device/${AXP_DEVICEVENDOR}/ -name 'Board*.mk');do
        for rserv in $BOARDRESERVATION;do
            grep -qE "^$rserv" $bmk \
                && sed -i -E "s/^(${rserv}.*)/#\1/g" $bmk
        done
    done
    
    git add -A && git commit --author="${AXP_GIT_AUTHOR} <${AXP_GIT_MAIL}>" -m "${AXP_DEVICE}: remove reserved space for AXP.OS" \
        && echo "[AXP] OK: freed-up reserved space!"
    cd $CPWD
else
    echo "[AXP] ... skipping free-up reserved space (AXP_LOW_STORAGE: $AXP_LOW_STORAGE)"
fi

echo "[AXP] ended with $? ..."
