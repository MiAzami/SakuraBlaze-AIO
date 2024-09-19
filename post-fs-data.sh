#!/system/bin/sh
# (C) Feravolt 2022
# (C) fastbooteraselk 2024
# Based on Brutal Busybox script.
MODDIR=${0%/*}

# Busybox functions
install_busybox()
{
if [ ! -e $MODDIR/system/bin/busybox ]; then
  cp -f /data/adb/magisk/busybox $MODDIR/system/bin
  chown 0:0 $MODDIR/system/bin/busybox
  chmod 775 $MODDIR/system/bin/busybox
  chcon u:object_r:system_file:s0 $MODDIR/system/bin/busybox
  $MODDIR/system/bin/busybox --install -s $MODDIR/system/bin/
  for sd in /system/bin/*; do
     rm -f $MODDIR/${sd}
  done
fi

# Print Busybox Version
BB_VER="$($a/busybox | head -n1 | cut -f1 -d'(')"

# Install into /system/bin, if exists.
if [ ! -e /system/xbin ]; then
	mkdir -p $MODPATH/system/bin
	mv -f $a/busybox $MODPATH/system/bin/busybox
	rm -Rf $a
	
fi
}

uninstall_busybox()
{
    rm -rf $MODDIR/system/xbin/busybox-arm64
    rm -rf $MODDIR/system/xbin/busybox
}


# Install built-in magisk busybox
#install_busybox

#uninstall_busybox

# Deepsleep functions
doze_disable()
{
   cmd tare clear-vip;for a in $(cmd package list packages -U google|sed "s/\ uid//g"|sort);do cmd app_hibernation set-state "$(echo $a|cut -f2 -d:)" true;cmd tare set-vip "$(echo $a|cut -f3 -d:)" "$(echo $a|cut -f2 -d:)" true;done
}

doze_enable()
{
    cmd tare clear-vip;for a in $(cmd package list packages -U google|sed "s/\ uid//g"|sort);do cmd app_hibernation set-state "$(echo $a|cut -f2 -d:)" false;cmd tare set-vip "$(echo $a|cut -f3 -d:)" "$(echo $a|cut -f2 -d:)" false;done
}

# Install gms doze patch
#gms_doze_patch
