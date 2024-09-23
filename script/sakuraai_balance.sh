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
LOG=/storage/emulated/0/SakuraAi/Balance.log

service call SurfaceFlinger 1008 i32 1

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
    
# CPU Governor
chmod 644 /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
chmod 644 /sys/devices/system/cpu/cpufreq/policy6/scaling_governor
echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy6/scaling_governor
echo "5000" > /sys/devices/system/cpu/cpufreq/policy6/schedutil/rate_limit_us
echo "5000" > /sys/devices/system/cpu/cpufreq/policy0/schedutil/rate_limit_us

# GPU Configure
echo "-1" > /proc/gpufreqv2/fix_target_opp_index
echo "simple_ondemand" > /sys/class/devfreq/mtk-dvfsrc-devfreq/governor
echo "simple_ondemand" > /sys/class/devfreq/13000000.mali/governor
echo "coarse_demand" > /sys/class/misc/mali0/device/power_policy

# CPU SET
chmod 644 /sys/devices/system/cpu/*/cpufreq/scaling_max_freq
chmod 644 /sys/devices/system/cpu/*/cpufreq/scaling_min_freq
for maf0 in /sys/devices/system/cpu
    do
        echo 1500000 > "$maf0/cpu0/cpufreq/scaling_max_freq"
        echo 1500000 > "$maf0/cpu1/cpufreq/scaling_max_freq"
        echo 1500000 > "$maf0/cpu2/cpufreq/scaling_max_freq"
        echo 1500000 > "$maf0/cpu3/cpufreq/scaling_max_freq"
        echo 1500000 > "$maf0/cpu4/cpufreq/scaling_max_freq"
        echo 1500000 > "$maf0/cpu5/cpufreq/scaling_max_freq"
    done
    for mif0 in /sys/devices/system/cpu
    do
        echo 500000 > "$mif0/cpu0/cpufreq/scaling_min_freq"
        echo 500000 > "$mif0/cpu1/cpufreq/scaling_min_freq"
        echo 500000 > "$mif0/cpu2/cpufreq/scaling_min_freq"
        echo 500000 > "$mif0/cpu3/cpufreq/scaling_min_freq"
        echo 500000 > "$mif0/cpu4/cpufreq/scaling_min_freq"
        echo 500000 > "$mif0/cpu5/cpufreq/scaling_min_freq"
    done
    for maf6 in /sys/devices/system/cpu
    do
        echo 22000000 > "$maf6/cpu6/cpufreq/scaling_max_freq"
        echo 22000000 > "$maf6/cpu7/cpufreq/scaling_max_freq"
    done
    for mif6 in /sys/devices/system/cpu
    do
        echo 725000 > "$mif6/cpu6/cpufreq/scaling_min_freq"
        echo 725000 > "$mif6/cpu7/cpufreq/scaling_min_freq"
    done
chmod 444 /sys/devices/system/cpu/*/cpufreq/scaling_max_freq
chmod 444 /sys/devices/system/cpu/*/cpufreq/scaling_min_freq

# Dislowpower
for dlp in /proc/displowpower
    do
        echo 1 > "$dlp/hrt_lp"
        echo 1 > "$dlp/idlevfp"
        echo 100 > "$dlp/idletime"
    done
    
# # scheduler
for sch in /proc/sys/kernel
    do
        echo 1000000 > "$sch/sched_migration_cost_ns"
        echo 45 > "$sch/perf_cpu_time_max_percent"
        echo 10000000 > "$sch/sched_latency_ns"
        echo 1000 > "$sch/sched_util_clamp_max"
        echo 100 > "$sch/sched_util_clamp_min"
        echo 1 > "$sch/sched_tunable_scaling"
        echo 1 > "$sch/sched_child_runs_first"
        echo 1 > "$sch/sched_energy_aware"
        echo 100000 > "$sch/sched_util_clamp_min_rt_default"
        echo 4194304 > "$sch/sched_deadline_period_max_us"
        echo 100 > "$sch/sched_deadline_period_min_us"
        echo 0 > "$sch/sched_schedstats"
        echo 3000000 > "$sch/sched_wakeup_granularity_ns"
        echo 30000000 > "$sch/sched_min_granularity_ns"
    done
    
for device in /sys/block/*
do
    # Skip if not a block device
    if [ ! -d "$device/queue" ]; then
        continue
    fi

    queue="$device/queue"
    
    # Check if the device is rotational (HDD) or non-rotational (SSD)
    rotational=$(cat "$queue/rotational")

    echo 0 > "$queue/add_random"
    echo 0 > "$queue/iostats"
    echo 2 > "$queue/nomerges"
    echo 2 > "$queue/rq_affinity"
    
    # If the device is SSD (rotational = 0), apply SSD-specific settings
    if [ "$rotational" -eq 0 ]; then
        echo 0 > "$queue/rotational"
    fi

    echo 128 > "$queue/nr_requests"
    echo 2048 > "$queue/read_ahead_kb"
done
# Power Level
for pl in /sys/devices/system/cpu/perf
    do
        echo 0 > "$pl/gpu_pmu_enable"
        echo 100000 > "$pl/gpu_pmu_period"
        echo 0 > "$pl/fuel_gauge_enable"
        echo 0 > "$pl/enable"
        echo 1 > "$pl/charger_enable"
    done
echo "on" > /sys/devices/system/cpu/power/control

# VirtualMemory
for vm in /proc/sys/vm
    do
        echo 35 > "$vm/dirty_background_ratio"
        echo 30 > "$vm/dirty_ratio"
        echo 100 > "$vm/vfs_cache_pressure"
        echo 400 > "$vm/dirty_expire_centisecs"
        echo 6000 > "$vm/dirty_writeback_centisecs"
        echo 0 > "$vm/oom_dump_tasks"
        echo 0 > "$vm/page-cluster"
        echo 0 > "$vm/block_dump"
        echo 10 > "$vm/stat_interval"
        echo 1 > "$vm/compaction_proactiveness"
        echo 1 > "$vm/watermark_boost_factor"
        echo 50 > "$vm/watermark_scale_factor"
        echo 2 > "$vm/drop_caches"
    done
    for sw in /dev/memcg
    do
        echo 50 > "$sw/memory.swappiness"
    done
# CPU SET
for cs in /dev/cpuset
    do
        echo 0-7 > "$cs/cpus"
        echo 0-5 > "$cs/background/cpus"
        echo 0-4 > "$cs/system-background/cpus"
        echo 0-7 > "$cs/foreground/cpus"
        echo 0-7 > "$cs/top-app/cpus"
        echo 0-5 > "$cs/restricted/cpus"
        echo 0-7 > "$cs/camera-daemon/cpus"
        echo 0 > "$cs/memory_pressure_enabled"
        echo 0 > "$cs/sched_load_balance"
        echo 0 > "$cs/foreground/sched_load_balance"
    done

sleep 1
# Set balance
setprop sakuraai.mode balance
echo " •> Sakura Bloom activated at $(date "+%H:%M:%S")" >> $LOG

# Report
sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ 🌸 Sakura Bloom ] /g' "$BASEDIR/module.prop"
am start -a android.intent.action.MAIN -e toasttext "🌸 Sakura Bloom" -n bellavita.toast/.MainActivity

exit 0
