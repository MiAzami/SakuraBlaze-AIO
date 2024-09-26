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

for cpu in /sys/devices/system/cpu/cpu[0-7]; do
    echo 1 > "$cpu/online"
done
    
for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    chmod 644 "$policy/scaling_governor"
    echo "performance" > "$policy/scaling_governor"
done

for device in /sys/class/devfreq/*; do
    if [ -f "$device/governor" ]; then
        chmod 644 "$device/governor"
        echo "performance" > "$device/governor"
    fi
done

if [ -d /proc/gpufreq ]; then
	gpu_freq="$(cat /proc/gpufreq/gpufreq_opp_dump | grep -o 'freq = [0-9]*' | sed 's/freq = //' | sort -nr | head -n 1)"
	apply "$gpu_freq" /proc/gpufreq/gpufreq_opp_freq
elif [ -d /proc/gpufreqv2 ]; then
	apply 0 /proc/gpufreqv2/fix_target_opp_index
fi

echo "coarse_demand" > /sys/class/misc/mali0/device/power_policy
echo 0 > /proc/ppm/enabled

chmod 644 /sys/devices/system/cpu/*/cpufreq/scaling_max_freq
chmod 644 /sys/devices/system/cpu/*/cpufreq/scaling_min_freq
for cpu in /sys/devices/system/cpu/cpu[0-3]; do
    echo 20000000 > "$cpu/cpufreq/scaling_max_freq"
done
for cpu in /sys/devices/system/cpu/cpu[0-3]; do
    echo 20000000 > "$cpu/cpufreq/scaling_min_freq"
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
        echo 0-5 > "$cs/restricted/cpus"
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
    echo 500000 > "$sch/sched_migration_cost_ns"
    echo 10 > "$sch/perf_cpu_time_max_percent"
    echo 10000000 > "$sch/sched_latency_ns"
    echo 1000 > "$sch/sched_util_clamp_max"
    echo 512 > "$sch/sched_util_clamp_min"
    echo 2 > "$sch/sched_tunable_scaling"
    echo 1 > "$sch/sched_child_runs_first"
    echo 0 > "$sch/sched_energy_aware"
    echo 250000 > "$sch/sched_util_clamp_min_rt_default"
    echo 2000000 > "$sch/sched_deadline_period_max_us"
    echo 100 > "$sch/sched_deadline_period_min_us"
    echo 0 > "$sch/sched_schedstats"
    echo 3000000 > "$sch/sched_wakeup_granularity_ns"
    echo 1000000 > "$sch/sched_min_granularity_ns"
done

for device in /sys/block/*
do
    if [ ! -d "$device/queue" ]; then
        continue
    fi
    queue="$device/queue"
    rotational=$(cat "$queue/rotational")

    echo 0 > "$queue/add_random"
    echo 0 > "$queue/iostats"
    echo 2 > "$queue/nomerges"
    echo 2 > "$queue/rq_affinity"
    if [ "$rotational" -eq 0 ]; then
        echo 0 > "$queue/rotational"
    fi
    echo 128 > "$queue/nr_requests"
    echo 2048 > "$queue/read_ahead_kb"
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
        echo 180 > "$vm/vfs_cache_pressure"
        echo 3000 > "$vm/dirty_expire_centisecs"
        echo 5000 > "$vm/dirty_writeback_centisecs"
        echo 0 > "$vm/oom_dump_tasks"
        echo 3 > "$vm/page-cluster"
        echo 0 > "$vm/block_dump"
        echo 10 > "$vm/stat_interval"
        echo 0 > "$vm/compaction_proactiveness"
        echo 1 > "$vm/watermark_boost_factor"
        echo 30 > "$vm/watermark_scale_factor"
        echo 2 > "$vm/drop_caches"
    done
    for sw in /dev/memcg
    do
        echo 30 > "$sw/memory.swappiness"
    done
am kill-all

# Set perf
setprop sakuraai.mode performance
echo " •> Gaming mode activated at $(date "+%H:%M:%S")" >> $LOG

# Report
sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ 🌸 Gaming Mode ] /g' "$BASEDIR/module.prop"
am start -a android.intent.action.MAIN -e toasttext "🌸 Gaming Mode" -n bellavita.toast/.MainActivity

exit 0
