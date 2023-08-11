#!/bin/bash
###############################################################################
#
# This code is part of AXP.OS - https://axp.binbash.rocks
# LICENSE: GPLv3
#
# Copyright (C) 2023 steadfasterX <steadfasterX -AT- gmail #DOT# com>
#
###############################################################################

# be strict on failures
#set -e

CPWD=$PWD
# get build vars (require a lunch before!)
export AXP_TARGET_VERSION=$(build/soong/soong_ui.bash --dumpvar-mode PLATFORM_VERSION  2>/dev/null)
export AXP_TARGET_ARCH=$(build/soong/soong_ui.bash --dumpvar-mode TARGET_ARCH  2>/dev/null)
export AXP_KERNEL_PATH=$(build/soong/soong_ui.bash --dumpvar-mode TARGET_KERNEL_SOURCE  2>/dev/null)
export AXP_KERNEL_CONF=$(build/soong/soong_ui.bash --dumpvar-mode TARGET_KERNEL_CONFIG  2>/dev/null)

# allow a custom OTA server URI, use default if unspecified
if [ -z "$CUSTOM_AXP_OTA_SERVER_URI" ];then
    export AXP_OTA_SERVER_URI="https://sfxota.binbash.rocks:8010/axp/a${AXP_TARGET_VERSION}/api/v1/{device}/{incr}"
else
    export AXP_OTA_SERVER_URI=$CUSTOM_AXP_OTA_SERVER_URI
fi
cd vendor/axp/overlays/packages/apps/Updater/app/src/main/res/values/ && git checkout strings.xml
cd $CPWD
sed -i "s|%%AXP_OTA_SERVER_URI%%|${AXP_OTA_SERVER_URI}|g" vendor/axp/overlays/packages/apps/Updater/app/src/main/res/values/strings.xml

# patch kernel source to build wireguard module
if [ ! -f "$AXP_KERNEL_PATH/.wg.patched" ];then
    cd $AXP_KERNEL_PATH
    ../../wireguard-linux-compat/kernel-tree-scripts/create-patch.sh | patch -p1 --no-backup-if-mismatch && touch .wg.patched && echo "[AXP] .. patched kernel sources for wireguard"
    cd $CPWD
    grep -q '^CONFIG_WIREGUARD=y' $AXP_KERNEL_PATH/arch/$AXP_TARGET_ARCH/configs/$AXP_KERNEL_CONF || echo CONFIG_WIREGUARD=y >> $AXP_KERNEL_PATH/arch/$AXP_TARGET_ARCH/configs/$AXP_KERNEL_CONF
    echo "[AXP] .. kernel config is set for wireguard"
fi