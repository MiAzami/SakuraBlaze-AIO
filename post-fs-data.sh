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

# Install built-in magisk busybox
#install_busybox
