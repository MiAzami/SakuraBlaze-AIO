#!/system/bin/sh
#By MiAzami

sync

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

# skiavk
skiavk()
{
    resetprop -n debug.hwui.renderer skiavk
    resetprop -n debug.renderengine.backend skiavkthreaded
    resetprop -n ro.hwui.use_vulkan 1
    resetprop -n ro.hwui.hardware.vulkan true
    resetprop -n ro.hwui.use_vulkan true
    resetprop -n ro.hwui.skia.show_vulkan_pipeline true
    resetprop -n persist.sys.disable_skia_path_ops false
    resetprop -n ro.config.hw_high_perf true
    resetprop -n debug.hwui.disable_scissor_opt true
    resetprop -n debug.vulkan.layers.enable 1
    resetprop -n debug.hwui.render_thread true
}

# skiagl
skiagl()
{
    resetprop -n debug.hwui.renderer skiagl
    resetprop -n vendor.debug.renderengine.backend skiaglthreaded
    resetprop -n debug.renderengine.backend skiaglthreaded
    resetprop -n debug.hwui.render_thread true
    resetprop -n debug.skia.threaded_mode true
    resetprop -n debug.hwui.render_thread_count 1
    resetprop -n debug.skia.num_render_threads 1
    resetprop -n debug.skia.render_thread_priority 1
    resetprop -n persist.sys.gpu.working_thread_priority 1
}

# disable overlay HW
doverlay()
{
    service call SurfaceFlinger 1008 i32 1
}

# Advanced FPSGO Settings
fpsgo()
{
    echo "15" > /sys/module/mtk_fpsgo/parameters/bhr_opp
    echo "1" > /sys/module/mtk_fpsgo/parameters/bhr_opp_l
    echo "90" > /sys/module/mtk_fpsgo/parameters/uboost_enhance_f
    echo "1" > /sys/module/mtk_fpsgo/parameters/gcc_fps_margin
    echo "90" > /sys/module/mtk_fpsgo/parameters/rescue_enhance_f
    echo "1" > /sys/module/mtk_fpsgo/parameters/qr_mod_frame
    echo "1" > /sys/module/mtk_fpsgo/parameters/fstb_separate_runtime_enable
    echo "1" > /sys/module/mtk_fpsgo/parameters/fstb_consider_deq
    echo "5" > /sys/pnpmgr/fpsgo_boost/fstb/fstb_tune_quantile
    echo "0" > /sys/pnpmgr/fpsgo_boost/fstb/fstb_tune_error_threshold
    echo "1" > /sys/pnpmgr/fpsgo_boost/fstb/margin_mode
    echo "10" > /sys/pnpmgr/fpsgo_boost/fbt/bhr_opp
    echo "1" > /sys/pnpmgr/fpsgo_boost/fbt/adjust_loading
    echo "1" > /sys/pnpmgr/fpsgo_boost/fbt/dyn_tgt_time_en
    echo "0" > /sys/pnpmgr/fpsgo_boost/fbt/floor_opp
    echo "90" > /sys/pnpmgr/fpsgo_boost/fbt/rescue_enhance_f
    echo "80" > /sys/module/mtk_fpsgo/parameters/run_time_percent
    echo "1" > /sys/module/mtk_fpsgo/parameters/loading_ignore_enable
    echo "80" > /sys/module/mtk_fpsgo/parameters/kmin
    echo "90" > /sys/pnpmgr/fpsgo_boost/fbt/rescue_opp_c
    echo "90" > /sys/pnpmgr/fpsgo_boost/fbt/rescue_opp_f
    echo "90" > /sys/pnpmgr/fpsgo_boost/fbt/rescue_percent
    echo "1" > /sys/pnpmgr/fpsgo_boost/fbt/ultra_rescue
    echo 100 > /sys/module/ged/parameters/gpu_cust_upbound_freq
    echo 100 > /sys/module/ged/parameters/gpu_cust_boost_freq
    echo 100 > /sys/pnpmgr/fpsgo_boost/fstb/fstb_tune_quantile
}

fpsgo2()
{
    # Set FPSGO fstb parameters
    echo 1 > /sys/kernel/fpsgo/fstb/boost_ta
    echo 0 > /sys/kernel/fpsgo/fstb/enable_switch_sync_flag

    # Set GPU boost level
    echo 101 > /sys/kernel/ged/hal/gpu_boost_level

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

su -lp 2000 -c "cmd notification post -S bigtext -t 'MTKVEST BLAZE' tag 'Waiting to Apply'" >/dev/null 2>&1

# Change zram
#change_zram

#skiavk

#skiagl

#doverlay

#fpsgo

#fpsgo2

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
echo "N" > /sys/module/printk/parameters/pid
echo "N" > /sys/module/printk/parameters/time
echo "1" > /proc/sys/kernel/sched_child_runs_first
echo "0" > /sys/kernel/ccci/debug

# Networking tweaks for low latency
echo "cubic" > /proc/sys/net/ipv4/tcp_congestion_control
echo 1 > /proc/sys/net/ipv4/tcp_low_latency
echo 1 > /proc/sys/net/ipv4/tcp_ecn
echo 1 > /proc/sys/net/ipv4/tcp_sack
echo 1 > /proc/sys/net/ipv4/tcp_timestamps
echo 3 > /proc/sys/net/ipv4/tcp_fastopen

#additional
echo "0-7" > /proc/irq/240/smp_affinity_list

# Done
sleep 1
sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ 🌦 Sakura will grow ] /g' "$MODDIR/module.prop"
su -lp 2000 -c "cmd notification post -S bigtext -t 'SakuraAI' tag '🌦 Sakura will grow'" >/dev/null 2>&1

# Run Ai
sleep 1
nohup sh $MODDIR/script/sakuraai_auto.sh &
