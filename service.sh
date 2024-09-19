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

# GED Hal ( Kernel) 
chmod 644 /sys/kernel/fpsgo/fstb/*
for fbt in /sys/kernel/fpsgo/fstb
    do
        echo 95 > "$fbt/boost_ta"
        echo 0 > "$fbt/enable_switch_sync_flag"
    done
    chmod 444 /sys/kernel/fpsgo/fstb/*
    
    
# GED Hal ( Kernel) 
for gedh in /sys/kernel/ged/hal
    do
        echo 95 > "$gedh/gpu_boost_level"
        echo 8 > "$gedh/loading_base_dvfs_step"
    done

# GED Parameter (Module) 
for gedp in /sys/module/ged/parameters
    do
        echo 120 > "$gedp/ged_smart_boost"
        echo 1 > "$gedp/enable_gpu_boost"
        echo 1 > "$gedp/ged_boost_enable"
        echo 1 > "$gedp/boost_gpu_enable"
        echo 1 > "$gedp/gpu_dvfs_enable"
        echo 95 > "$gedp/gx_fb_dvfs_margin"
        echo 100 > "$gedp/gpu_idle"
        echo 0 > "$gedp/is_GED_KPI_enabled"
	done

# FPSGo (PNPMGR) 
for pnp in /sys/pnpmgr
    do
        echo 1 > "$pnp/fpsgo_boost/boost_mode"
        echo 1 > "$pnp/install"
        echo 1 > "$pnp/mwn"
        echo 100 > "$pnp/fpsgo_boost/fstb/fstb_tune_quantile"
        echo 120 > "$pnp/fpsgo_boost/fstb/fstb_fix_fps"
    done
    
# MTKFPS GO Parameter
for fpsp in /sys/module/mtk_fpsgo/parameters
    do
        echo 120 > "$fpsp/boost_affinity"
        echo 120 > "$fpsp/boost_LR"
        echo 120 > "$fpsp/xgf_uboost"
    done
    
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

# Done
sleep 1
sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ 🌦 Sakura will grow ] /g' "$MODDIR/module.prop"
su -lp 2000 -c "cmd notification post -S bigtext -t 'SakuraAI' tag '🌦 Sakura will grow'" >/dev/null 2>&1

# Run Ai
sleep 1
nohup sh $MODDIR/script/sakuraai_auto.sh &
