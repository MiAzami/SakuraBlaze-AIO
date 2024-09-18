#!/system/bin/sh
# Sync to data in the rare case a device crashes
sync

# Functions
read_file(){
  if [[ -f $1 ]]; then
    if [[ ! -r $1 ]]; then
      chmod +r "$1"
    fi
    cat "$1"
  else
    echo "File $1 not found"
  fi
}

# Path
BASEDIR=/data/adb/modules/SakuraAi
LOG=/storage/emulated/0/SakuraAi/Performance.log

service call SurfaceFlinger 1008 i32 1

# GED Hal ( Kernel) 
chmod 644 /sys/kernel/fpsgo/fstb/*
for fbt in /sys/kernel/fpsgo/fstb
    do
        echo 95 > "$fbt/boost_ta"
        echo 0 > "$fbt/enable_switch_sync_flag"
    done
    chmod 444 /sys/kernel/fpsgo/fstb/*
    
# GED Hal ( Kernel) 
chmod 644 /sys/kernel/fpsgo/fbt/*
for fstb in /sys/kernel/fpsgo/fbt
    do
        echo 120 > "$fstb/set_render_max_fps"
    chmod 444 /sys/kernel/fpsgo/fbt/*
    done
    
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

# CPU SET
for cpus in /sys/devices/system/cpu
    do
        echo 1 > "$cpus/cpu0/online"
        echo 1 > "$cpus/cpu1/online"
        echo 1 > "$cpus/cpu2/online"
        echo 1 > "$cpus/cpu3/online"
        echo 1 > "$cpus/cpu4/online"
        echo 1 > "$cpus/cpu5/online"
        echo 1 > "$cpus/cpu6/online"
        echo 1 > "$cpus/cpu7/online"
    done
    
#  Governor CPU0
chmod 644 /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
echo "performance" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
#  Governor CPU6
chmod 644 /sys/devices/system/cpu/cpufreq/policy6/scaling_governor
echo "performance" > /sys/devices/system/cpu/cpufreq/policy6/scaling_governor

# GPU Governor
echo "performance" > /sys/class/devfreq/mtk-dvfsrc-devfreq/governor
echo "performance" > /sys/class/devfreq/13000000.mali/governor
echo "00" > /proc/gpufreqv2/fix_target_opp_index
echo "1100000 75000" > /proc/gpufreqv2/fix_custom_freq_volt
echo "on" > /proc/gpufreqv2/mfgsys_power_control
echo "1" > /proc/gpufreqv2/gpm_mode
echo "coarse_demand" > /sys/class/misc/mali0/device/power_policy

# CPU SET
chmod 644 /sys/devices/system/cpu/*/cpufreq/scaling_max_freq
chmod 644 /sys/devices/system/cpu/*/cpufreq/scaling_min_freq
for maf0 in /sys/devices/system/cpu
    do
        echo 20000000 > "$maf0/cpu0/cpufreq/scaling_max_freq"
        echo 20000000 > "$maf0/cpu1/cpufreq/scaling_max_freq"
        echo 20000000 > "$maf0/cpu2/cpufreq/scaling_max_freq"
        echo 20000000 > "$maf0/cpu3/cpufreq/scaling_max_freq"
        echo 20000000 > "$maf0/cpu4/cpufreq/scaling_max_freq"
        echo 20000000 > "$maf0/cpu5/cpufreq/scaling_max_freq"
    done
    for mif0 in /sys/devices/system/cpu
    do
        echo 20000000 > "$mif0/cpu0/cpufreq/scaling_min_freq"
        echo 20000000 > "$mif0/cpu1/cpufreq/scaling_min_freq"
        echo 20000000 > "$mif0/cpu2/cpufreq/scaling_min_freq"
        echo 20000000 > "$mif0/cpu3/cpufreq/scaling_min_freq"
        echo 20000000 > "$mif0/cpu4/cpufreq/scaling_min_freq"
        echo 20000000 > "$mif0/cpu5/cpufreq/scaling_min_freq"
    done
    for maf6 in /sys/devices/system/cpu
    do
        echo 22000000 > "$maf6/cpu6/cpufreq/scaling_max_freq"
        echo 22000000 > "$maf6/cpu7/cpufreq/scaling_max_freq"
    done
    for mif6 in /sys/devices/system/cpu
    do
        echo 20000000 > "$mif6/cpu6/cpufreq/scaling_min_freq"
        echo 20000000 > "$mif6/cpu7/cpufreq/scaling_min_freq"
    done
chmod 444 /sys/devices/system/cpu/*/cpufreq/scaling_max_freq
chmod 444 /sys/devices/system/cpu/*/cpufreq/scaling_min_freq

# CPU SET
for cs in /dev/cpuset
    do
        echo 0-7 > "$cs/cpus"
        echo 0-7 > "$cs/background/cpus"
        echo 0-3 > "$cs/system-background/cpus"
        echo 0-7 > "$cs/foreground/cpus"
        echo 0-7 > "$cs/top-app/cpus"
        echo 0-3 > "$cs/restricted/cpus"
        echo 0-7 > "$cs/camera-daemon/cpus"
        echo 0 > "$cs/memory_pressure_enabled"
        echo 0 > "$cs/sched_load_balance"
        echo 0 > "$cs/foreground/sched_load_balance"
    done

# Dislowpower
for dlp in /proc/displowpower
    do
        echo 1 > "$dlp/hrt_lp"
        echo 1 > "$dlp/idlevfp"
        echo 100 > "$dlp/idletime"
    done
    
# scheduler
for sch in /proc/sys/kernel
do
    echo 100000 > "$sch/sched_migration_cost_ns"
    echo 5 > "$sch/perf_cpu_time_max_percent"
    echo 200000 > "$sch/sched_latency_ns"
    echo 1024 > "$sch/sched_util_clamp_max"
    echo 512 > "$sch/sched_util_clamp_min"
    echo 2 > "$sch/sched_tunable_scaling"
    echo 1 > "$sch/sched_child_runs_first"
    echo 0 > "$sch/sched_energy_aware"
    echo 8 > "$sch/sched_nr_migrate"
    echo 2 > "$sch/sched_pelt_multiplier"
    echo 25 > "$sch/sched_util_clamp_min_rt_default"
    echo 200 > "$sch/sched_deadline_period_max_us"
    echo 100 > "$sch/sched_deadline_period_min_us"
    echo 0 > "$sch/sched_schedstats"
    echo 3000000 > "$sch/sched_wakeup_granularity_ns"
    echo 1000000 > "$sch/sched_min_granularity_ns"
done

    for sda in /sys/block/sda/queue
    do
        echo 0 > "$sda/add_random"
        echo 0 > "$sda/iostats"
        echo 2 > "$sda/nomerges"
        echo 2 > "$sda/rq_affinity"
        echo 0 > "$sda/rotational"
        echo 256 > "$sda/nr_requests"
        echo 4096 > "$sda/read_ahead_kb"
    done
    for sdb in /sys/block/sdb/queue
    do
        echo 0 > "$sdb/add_random"
        echo 0 > "$sdb/iostats"
        echo 2 > "$sdb/nomerges"
        echo 2 > "$sdb/rq_affinity"
        echo 0 > "$sdb/rotational"
        echo 256 > "$sdb/nr_requests"
        echo 4096 > "$sdb/read_ahead_kb"
    done
    for sdc in /sys/block/sdc/queue
    do
        echo 0 > "$sdc/add_random"
        echo 0 > "$sdc/iostats"
        echo 2 > "$sdc/nomerges"
        echo 2 > "$sdc/rq_affinity"
        echo 0 > "$sdc/rotational"
        echo 256 > "$sdc/nr_requests"
        echo 4096 > "$sdc/read_ahead_kb"
    done
    for dm0 in /sys/block/dm-0/queue
    do
        echo 0 > "$dm0/add_random"
        echo 0 > "$dm0/iostats"
        echo 2 > "$dm0/nomerges"
        echo 2 > "$dm0/rq_affinity"
        echo 0 > "$dm0/rotational"
        echo 256 > "$dm0/nr_requests"
        echo 4096 > "$dm0/read_ahead_kb"
    done
        # I/O scheduler
    for queue in /sys/block/*/queue
    do
        echo 4096 > "$queue/read_ahead_kb"
        echo 256 > "$queue/nr_requests"
        echo 2 > "$queue/rq_affinity"
        echo 2 > "$dm0/nomerges"
        echo 0 > "$queue/add_random"
        echo 0 > "$queue/iostats"
        echo 0 > "$dm0/rotational"
    done

# Power Level
for pl in /sys/devices/system/cpu/perf
    do
        echo 1 > "$pl/gpu_pmu_enable"
        echo 1000000 > "$pl/gpu_pmu_period"
        echo 1 > "$pl/fuel_gauge_enable"
        echo 1 > "$pl/enable"
        echo 1 > "$pl/charger_enable"
    done

# VirtualMemory
for vm in /proc/sys/vm
    do
        echo 10 > "$vm/dirty_background_ratio"
        echo 15 > "$vm/dirty_ratio"
        echo 100 > "$vm/vfs_cache_pressure"
        echo 3000 > "$vm/dirty_expire_centisecs"
        echo 5000 > "$vm/dirty_writeback_centisecs"
        echo 0 > "$vm/oom_dump_tasks"
        echo 3 > "$vm/page-cluster"
        echo 0 > "$vm/block_dump"
        echo 10 > "$vm/stat_interval"
        echo 0 > "$vm/compaction_proactiveness"
        echo 1 > "$vm/watermark_boost_factor"
        echo 100 > "$vm/watermark_scale_factor"
        echo 3 > "$vm/drop_caches"
    done
    for sw in /dev/memcg
    do
        echo 30 > "$sw/memory.swappiness"
        echo 30 > "$sw/apps/memory.swappiness"
        echo 55 > "$sw/system/memory.swappiness"
    done


# force stop
am force-stop com.instagram.android
am force-stop com.android.vending
am force-stop app.grapheneos.camera
am force-stop com.google.android.gm
am force-stop com.google.android.apps.youtube.creator
am force-stop com.dolby.ds1appUI
am force-stop com.google.android.youtube
am force-stop com.twitter.android
am force-stop nekox.messenger
am force-stop com.shopee.id
am force-stop com.vanced.android.youtube
am force-stop com.speedsoftware.rootexplorer
am force-stop com.bukalapak.android
am force-stop org.telegram.messenger
am force-stop ru.zdevs.zarchiver
am force-stop com.android.chrome
am force-stop com.google.android.GoogleCameraEng
am force-stop com.facebook.orca
am force-stop com.lazada.android
am force-stop com.android.camera
am force-stop com.android.settings
am force-stop com.franco.kernel
am force-stop com.telkomsel.telkomselcm
am force-stop com.facebook.katana
am force-stop com.instagram.android
am force-stop com.facebook.lite
am kill-all

settings put system min_refresh_rate 120
settings put system peak_refresh_rate 120

# Set perf
setprop sakuraai.mode performance
echo " •> Gaming mode activated at $(date "+%H:%M:%S")" >> $LOG

# Report
sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ 🌸 Gaming Mode ] /g' "$BASEDIR/module.prop"
am start -a android.intent.action.MAIN -e toasttext "🌸 Gaming Mode" -n bellavita.toast/.MainActivity

exit 0