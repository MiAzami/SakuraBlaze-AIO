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
        sleep 4
    done
    # we doesn't have the permission to rw "/sdcard" before the user unlocks the screen
    while [ ! -d "/sdcard/Android" ]; do
        sleep 2
    done
}

# Variables
ZRAMSIZE=0
SWAPSIZE=0

# Zram functions
disable_zram()
{
    swapoff /dev/block/zram0
    echo "0" > /sys/class/zram-control/hot_remove
}

change_zram()
{
    sleep 5
    swapoff /dev/block/zram0
    echo "1" > /sys/block/zram0/reset
    echo "$ZRAMSIZE" > /sys/block/zram0/disksize
    mkswap /dev/block/zram0
    swapon /dev/block/zram0
}

# Enable all tweak
sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ 🍃 Planting sakura seeds ] /g' "$MODDIR/module.prop"
su -lp 2000 -c "cmd notification post -S bigtext -t 'SakuraAI' tag '🍃 Planting sakura seeds'" >/dev/null 2>&1

# Sync to data in the rare case a device crashes
sync

# Change zram
#change_zram

echo "1" > /sys/module/mtk_core_ctl/parameters/policy_enable
echo N > /sys/module/sync/parameters/fsync_enabled

# Scheduler I/O
echo "deadline" > /sys/block/sda/queue/scheduler
echo "deadline" > /sys/block/sdb/queue/scheduler
echo "deadline" > /sys/block/sdc/queue/scheduler

#printk
echo "0 0 0 0" > /proc/sys/kernel/printk
echo "1" > /sys/module/printk/parameters/console_suspend
echo "1" > /sys/module/printk/parameters/ignore_loglevel
echo "0" > /sys/module/printk/parameters/time
echo "off" > /proc/sys/kernel/printk_devkmsg

# Networking tweaks
echo "cubic" > /proc/sys/net/ipv4/tcp_congestion_control
echo "1" > /proc/sys/net/ipv4/tcp_low_latency
echo "1" > /proc/sys/net/ipv4/tcp_ecn
echo "1" > /proc/sys/net/ipv4/tcp_sack
echo "1" > /proc/sys/net/ipv4/tcp_timestamps

#SurfaceFlinger 
resetprop -n persist.sys.phh.enable_sf_gl_backpressure 0
resetprop -n persist.sys.phh.enable_sf_hwc_backpressure 0
resetprop -n debug.sf.disable_client_composition_cache 1
resetprop -n debug.sf.latch_unsignaled 1
resetprop -n debug.sf.disable_backpressure 1
resetprop -n debug.sf.enable_gl_backpressure 0
resetprop -n debug.sf.enable_hwc_vds 1
resetprop -n persist.sys.sf.native_mode 1
resetprop -n debug.sf.hw 1
resetprop -n debug.sf.enable_layer_caching 0

# Done
sleep 1
sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ 🌦 Sakura will grow ] /g' "$MODDIR/module.prop"
su -lp 2000 -c "cmd notification post -S bigtext -t 'SakuraAI' tag '🌦 Sakura will grow'" >/dev/null 2>&1

# Run Ai
sleep 1
nohup sh $MODDIR/script/sakuraai_auto.sh &
