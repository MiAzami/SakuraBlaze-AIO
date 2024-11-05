#!/system/bin/sh
#By MiAzami
#!/bin/sh
while [ "$(getprop sys.boot_completed | tr -d '\r')" != "1" ]; do
    sleep 5
done

MODDIR=${0%/*}

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

# disable overlay HW
doverlay()
{
    service call SurfaceFlinger 1008 i32 1
}

# Advanced FPSGO Settings
fpsgo()
{
    echo "31" > /sys/module/mtk_fpsgo/parameters/bhr_opp
    echo "0" > /sys/module/mtk_fpsgo/parameters/bhr_opp_l
    echo "1" > /sys/module/mtk_fpsgo/parameters/uboost_enhance_f
    echo "90" > /sys/module/mtk_fpsgo/parameters/rescue_enhance_f
    echo "1" > /sys/module/mtk_fpsgo/parameters/qr_mod_frame
    echo "1" > /sys/module/mtk_fpsgo/parameters/fstb_separate_runtime_enable
    echo "1" > /sys/module/mtk_fpsgo/parameters/fstb_consider_deq
    echo "5" > /sys/pnpmgr/fpsgo_boost/fstb/fstb_tune_quantile
    echo "1" > /sys/pnpmgr/fpsgo_boost/fstb/fstb_tune_error_threshold
    echo "10" > /sys/pnpmgr/fpsgo_boost/fbt/bhr_opp
    echo "0" > /sys/pnpmgr/fpsgo_boost/fbt/floor_opp
    echo "90" > /sys/pnpmgr/fpsgo_boost/fbt/rescue_enhance_f
    echo "100" > /sys/module/mtk_fpsgo/parameters/run_time_percent
    echo "1" > /sys/module/mtk_fpsgo/parameters/loading_ignore_enable
    echo "120" > /sys/module/mtk_fpsgo/parameters/kmin
    echo "60" > /sys/pnpmgr/fpsgo_boost/fbt/rescue_opp_c
    echo "80" > /sys/pnpmgr/fpsgo_boost/fbt/rescue_opp_f
    echo "90" > /sys/pnpmgr/fpsgo_boost/fbt/rescue_percent
    echo "1" > /sys/pnpmgr/fpsgo_boost/fbt/ultra_rescue
    echo 0 > /sys/module/ged/parameters/gpu_cust_upbound_freq
    echo 100 > /sys/module/ged/parameters/gpu_cust_boost_freq
}

fpsgo2()
{
    # Set FPSGO fstb parameters
    echo 1 > /sys/kernel/fpsgo/fstb/boost_ta
    echo 0 > /sys/kernel/fpsgo/fstb/enable_switch_sync_flag

    # Set GPU boost level
    echo -1 > /sys/kernel/ged/hal/gpu_boost_level

    # Set GED parameters
    echo 1 > /sys/module/ged/parameters/ged_smart_boost
    echo 1 > /sys/module/ged/parameters/enable_gpu_boost
    echo 1 > /sys/module/ged/parameters/ged_boost_enable
    echo 1 > /sys/module/ged/parameters/boost_gpu_enable
    echo 1 > /sys/module/ged/parameters/gpu_dvfs_enable
    echo 1 > /sys/module/ged/parameters/gpu_idle
    echo 0 > /sys/module/ged/parameters/is_GED_KPI_enabled

    # Set additional GPU boost parameters
    echo 1 > /sys/module/ged/parameters/gx_frc_mode
    echo 1 > /sys/module/ged/parameters/gx_boost_on
    echo 1 > /sys/module/ged/parameters/gx_game_mode
    echo 1 > /sys/module/ged/parameters/gx_3D_benchmark_on
    echo 1 > /sys/module/ged/parameters/cpu_boost_policy
    echo 1 > /sys/module/ged/parameters/boost_extra

    # Set PNPMGR parameters
    echo 1 > /sys/pnpmgr/fpsgo_boost/boost_mode
    echo 1 > /sys/pnpmgr/install
    echo 1 > /sys/pnpmgr/mwn

    # Set MTK FPSGo parameters
    echo 1 > /sys/module/mtk_fpsgo/parameters/boost_affinity
    echo 1 > /sys/module/mtk_fpsgo/parameters/boost_LR
    echo 1 > /sys/module/mtk_fpsgo/parameters/xgf_uboost
}

# Enable all tweak

su -lp 2000 -c "cmd notification post -S bigtext -t 'Sakura AI' tag 'Waiting to Apply'" >/dev/null 2>&1

# Change zram
#change_zram

#doverlay

#fpsgo

#fpsgo2

sleep 5

# Set kernel scheduler parameters for specific apps/libraries
echo "com.miHoYo.,com.HoYoverse.,UnityMain,libunity.so" > /proc/sys/kernel/sched_lib_name
echo 255 > /proc/sys/kernel/sched_lib_mask_force

# Set the I/O scheduler to "deadline" for all block devices
for device in /sys/block/*; do
    queue="$device/queue"
    if [ -f "$queue/scheduler" ]; then
        echo "deadline" > "$queue/scheduler"
    fi
done

# Disable fsync
echo N > /sys/module/sync/parameters/fsync_enabled

# Kernel performance configuration
echo "0 0 0 0" > /proc/sys/kernel/printk
echo "off" > /proc/sys/kernel/printk_devkmsg
echo "Y" > /sys/module/printk/parameters/console_suspend
echo "N" > /sys/module/printk/parameters/cpu
echo "0" > /sys/kernel/printk_mode/printk_mode
echo "Y" > /sys/module/printk/parameters/ignore_loglevel

# DisableHotPlug
for cpu in /sys/devices/system/cpu/cpu[1-7] /sys/devices/system/cpu/cpu1[0-7]; do
    echo "0" > $cpu/core_ctl/enable
    echo "0" > $cpu/core_ctl/core_ctl_boost
done

# DevStune
for path in /dev/stune/*; do
    base=$(basename "$path")  
    if [[ "$base" == "top-app" || "$base" == "foreground" ]]; then
        echo 1 > "$path/schedtune.boost"
        echo 1 > "$path/schedtune.sched_boost_enabled"
    else
        echo 1 > "$path/schedtune.boost"
        echo 1 > "$path/schedtune.sched_boost_enabled"
    fi  
    echo 0 > "$path/schedtune.prefer_idle"
    echo 0 > "$path/schedtune.colocate"
done

# Kernel Optimized
echo 64 > /proc/sys/kernel/sched_nr_migrate
echo 100000 > /proc/sys/kernel/sched_migration_cost_ns
echo 1000000 > /proc/sys/kernel/sched_min_granularity_ns

# Virtual Memory Optimized
echo 250 > /proc/sys/vm/watermark_scale_factor
echo 250 > /proc/sys/vm/watermark_boost_factor
echo 100 > /proc/sys/vm/stat_interval

# Networking tweaks for low latency
echo "cubic" > /proc/sys/net/ipv4/tcp_congestion_control
echo 1 > /proc/sys/net/ipv4/tcp_low_latency
echo 1 > /proc/sys/net/ipv4/tcp_ecn
echo 1 > /proc/sys/net/ipv4/tcp_sack
echo 3 > /proc/sys/net/ipv4/tcp_fastopen

for zone in /sys/class/thermal/thermal_zone*; do
    if [ -f "$zone/trip_point_0_temp" ]; then
        echo 999999999 > "$zone/trip_point_0_temp"
        echo "Set $zone/trip_point_0_temp to 999999999"
    fi
done

sleep 1

su -lp 2000 -c "cmd notification post -S bigtext -t 'Sakura AI' tag 'Tweak Applied'" >/dev/null 2>&1

nohup sh $MODDIR/script/sakuraai_auto.sh &