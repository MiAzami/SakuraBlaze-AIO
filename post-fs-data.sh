#!/system/bin/sh
# (C) Feravolt 2022
# (C) fastbooteraselk 2024
# Based on Brutal Busybox script.
MODDIR=${0%/*}

if ! [ -f "$MODDIR/installed" ]; then
	if [ -d "$MODDIR/system/bin" ]; then
		chown 0:0 $MODDIR/system/bin/busybox
		chmod 775 $MODDIR/system/bin/busybox
		chcon u:object_r:system_file:s0 $MODDIR/system/bin/busybox
		$MODDIR/system/bin/busybox --install -s $MODDIR/system/bin/
		for sd in /system/bin/*; do
			rm -f $MODDIR/${sd}
		done
	fi
	if [ -d "$MODDIR/system/xbin" ]; then
		chown 0:0 $MODDIR/system/xbin/busybox
		chmod 775 $MODDIR/system/xbin/busybox
		chcon u:object_r:system_file:s0 $MODDIR/system/xbin/busybox
		$MODDIR/system/xbin/busybox --install -s $MODDIR/system/xbin/
	fi
	touch $MODDIR/installed
fi

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
