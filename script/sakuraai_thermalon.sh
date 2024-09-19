#!/system/bin/sh
#By MiAzami

# Waiting for boot completed
while [ "$(getprop sys.boot_completed | tr -d '\r')" != "1" ]; do sleep 5; done

# Path
MODDIR=${0%/*}

# Device online functions
wait_until_login()
{
    # whether in lock screen, tested on Android 7.1 & 10.0
    # in case of other magisk module remounting /data as RW
    while [ "$(dumpsys window policy | grep mInputRestricted=true)" != "" ]; do
        sleep 2
    done
    # we doesn't have the permission to rw "/sdcard" before the user unlocks the screen
    while [ ! -d "/sdcard/Android" ]; do
        sleep 2
    done
}

# Sync to data in the rare case a device crashes
sync

echo "1" > /sys/kernel/thermal_trace/enable
echo "1" > /sys/kernel/thermal_trace/hr_enable
echo "1000000" > /sys/kernel/thermal_trace/hr_period

start thermald
start thermal_core
start vendor.thermal-hal-2-0.mtk
start mi_thermald

resetprop -n -v ro.esports.thermal_config.support 1
resetprop -n -v dalvik.vm.dexopt.thermal-cutoff 2

for a in $(getprop|grep thermal|cut -f1 -d]|cut -f2 -d[|grep -F init.svc.|sed 's/init.svc.//');do start $a;done;for b in $(getprop|grep thermal|cut -f1 -d]|cut -f2 -d[|grep -F init.svc.);do start $b;done;for c in $(getprop|grep thermal|cut -f1 -d]|cut -f2 -d[|grep -F init.svc_);do start $c;done;for e in $(find /sys/ -name throttling);do start "$(echo $d|cut -d. -f3)";done

# Set on
setprop thermal.mode on
echo " •> Thermal On at $(date "+%H:%M:%S")" >> $LOG

# Run Ai
sleep 1
nohup sh $MODDIR/script/sakuraai_auto.sh &
