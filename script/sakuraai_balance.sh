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

# Find Mali GPU directory
mali_dir=$(ls -d /sys/devices/platform/soc/*mali* 2>/dev/null)

if [ -n "$mali_dir" ]; then
    echo "Mali directory found at: $mali_dir"

    # Set values directly if files exist
    if [ -f "$mali_dir/js_ctx_scheduling_mode" ]; then
        echo 1 > "$mali_dir/js_ctx_scheduling_mode" && echo "Successfully set $mali_dir/js_ctx_scheduling_mode to 0"
    else
        echo "$mali_dir/js_ctx_scheduling_mode not found"
    fi

    if [ -f "$mali_dir/js_scheduling_period" ]; then
        echo 0 > "$mali_dir/js_scheduling_period" && echo "Successfully set $mali_dir/js_scheduling_period to 0"
    else
        echo "$mali_dir/js_scheduling_period not found"
    fi

    if [ -f "$mali_dir/dvfs_period" ]; then
        echo 100 > "$mali_dir/dvfs_period" && echo "Successfully set $mali_dir/dvfs_period to 100"
    else
        echo "$mali_dir/dvfs_period not found"
    fi
fi


# CPU SET
for cpu in /sys/devices/system/cpu/cpu[0-7]; do
    echo 1 > "$cpu/online"
done

for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    chmod 644 "$policy/scaling_governor"
    echo "schedutil" > "$policy/scaling_governor"
    if [ -f "$policy/schedutil/rate_limit_us" ]; then
        chmod 644 "$policy/schedutil/rate_limit_us"
        echo "4000" > "$policy/schedutil/rate_limit_us"
    fi
done

for device in /sys/class/devfreq/*; do
    if [ -f "$device/governor" ]; then
        chmod 644 "$device/governor"
        echo "simple_ondemand" > "$device/governor"
    fi
done

if [ -d /proc/gpufreq ]; then
    apply "0" /proc/gpufreq/gpufreq_opp_freq 2>/dev/null
elif [ -d /proc/gpufreqv2 ]; then
    apply -1 /proc/gpufreqv2/fix_target_opp_index
fi

echo "coarse_demand" > /sys/class/misc/mali0/device/power_policy

echo 0 1 > /proc/ppm/policy_status  # Disable PTPOD
echo 1 1 > /proc/ppm/policy_status  # Disable UT (Uplink Throttling)
echo 2 1 > /proc/ppm/policy_status  # Disable FORCE_LIMIT
echo 3 1 > /proc/ppm/policy_status  # Disable PWR_THRO
echo 4 1 > /proc/ppm/policy_status  # Disable THERMAL
echo 5 1 > /proc/ppm/policy_status  # Disable DLPT
echo 7 1 > /proc/ppm/policy_status  # Disable USER_LIMIT
echo 8 1 > /proc/ppm/policy_status  # Disable LCM_OFF (Display off throttling)

# Disable
echo 6 0 > /proc/ppm/policy_status  # Enable HARD_USER_LIMIT
echo 9 0 > /proc/ppm/policy_status  # Enable SYS_BOOST

chmod 644 /sys/devices/system/cpu/*/cpufreq/scaling_max_freq
chmod 644 /sys/devices/system/cpu/*/cpufreq/scaling_min_freq

# Manage frequency limits for CPU clusters
cluster=0
for path in /sys/devices/system/cpu/cpufreq/policy*; do
    available_freqs=$(cat "$path/scaling_available_frequencies" 2>/dev/null)

    if [ -n "$available_freqs" ]; then
        max_freq=$(echo "$available_freqs" | cut -d' ' -f6)  
        min_freq=$(echo "$available_freqs" | awk '{print $NF}')  

        echo "$cluster $min_freq" > /proc/ppm/policy/hard_userlimit_min_cpu_freq
        echo "$cluster $max_freq" > /proc/ppm/policy/hard_userlimit_max_cpu_freq
    fi

    cluster=$((cluster + 1))  
done

for cpu in /sys/devices/system/cpu/cpu[0-7]; do  
    if [ -d "$cpu/cpufreq" ]; then
        available_freqs=$(cat "$cpu/cpufreq/scaling_available_frequencies" 2>/dev/null)

        if [ -n "$available_freqs" ]; then
            min_freq=$(echo "$available_freqs" | awk '{print $NF}')
            max_freq=$(echo "$available_freqs" | cut -d' ' -f6)

            echo "$max_freq" > "$cpu/cpufreq/scaling_max_freq"
            echo "$min_freq" > "$cpu/cpufreq/scaling_min_freq"
        fi
    fi
done

# Reset permissions to read-only for scaling frequencies
chmod 444 /sys/devices/system/cpu/*/cpufreq/scaling_max_freq
chmod 444 /sys/devices/system/cpu/*/cpufreq/scaling_min_freq


# Check if the gpufreq_limit_table file exists
if [ -f "/proc/gpufreq/gpufreq_limit_table" ]; then
    {
        echo "ignore_batt_oc 0"
        echo "ignore_batt_percent 0"
        echo "ignore_batt_low 0"
        echo "ignore_thermal 0"
        echo "ignore_pbm 0"
    } >> /proc/gpufreq/gpufreq_limit_table
fi

echo 1 > /sys/devices/system/cpu/eas/enable
echo 1 > /proc/cpufreq/cpufreq_power_mode
echo 0 > /proc/cpufreq/cpufreq_cci_mode
echo 0 > /proc/cpufreq/cpufreq_sched_disable
echo 1 > /proc/gpufreq/gpufreq_power_limited

# Disallow power saving mode for display
for dlp in /proc/displowpower/*; do
    [ -f "$dlp/hrt_lp" ] && echo 1 > "$dlp/hrt_lp"
    [ -f "$dlp/idlevfp" ] && echo 1 > "$dlp/idlevfp"
    [ -f "$dlp/idletime" ] && echo 100 > "$dlp/idletime"
done

# Scheduler parameters with specific values for each
echo 1000000 > /proc/sys/kernel/sched_migration_cost_ns
echo 45 > /proc/sys/kernel/perf_cpu_time_max_percent
echo 10000000 > /proc/sys/kernel/sched_latency_ns
echo 1000 > /proc/sys/kernel/sched_util_clamp_max
echo 100 > /proc/sys/kernel/sched_util_clamp_min
echo 1 > /proc/sys/kernel/sched_tunable_scaling
echo 1 > /proc/sys/kernel/sched_child_runs_first
echo 1 > /proc/sys/kernel/sched_energy_aware
echo 100000 > /proc/sys/kernel/sched_util_clamp_min_rt_default
echo 4194304 > /proc/sys/kernel/sched_deadline_period_max_us
echo 100 > /proc/sys/kernel/sched_deadline_period_min_us
echo 0 > /proc/sys/kernel/sched_schedstats
echo 3000000 > /proc/sys/kernel/sched_wakeup_granularity_ns
echo 30000000 > /proc/sys/kernel/sched_min_granularity_ns

# Block device settings
for device in /sys/block/*/queue; do
    if [ -d "$device" ]; then
        echo 0 > "$device/add_random"
        echo 0 > "$device/iostats"
        echo 2 > "$device/nomerges"
        echo 2 > "$device/rq_affinity"
        if [ "$(cat "$device/rotational")" -eq 0 ]; then
            echo 0 > "$device/rotational"
        fi
        echo 128 > "$device/nr_requests"
        echo 4096 > "$device/read_ahead_kb"
    fi
done

# Power level settings
for pl in /sys/devices/system/cpu/perf/*; do
    [ -f "$pl/gpu_pmu_enable" ] && echo 0 > "$pl/gpu_pmu_enable"
    [ -f "$pl/gpu_pmu_period" ] && echo 100000 > "$pl/gpu_pmu_period"
    [ -f "$pl/fuel_gauge_enable" ] && echo 0 > "$pl/fuel_gauge_enable"
    [ -f "$pl/charger_enable" ] && echo 1 > "$pl/charger_enable"
done

# Virtual memory settings
echo 35 > /proc/sys/vm/dirty_background_ratio
echo 30 > /proc/sys/vm/dirty_ratio
echo 120 > /proc/sys/vm/vfs_cache_pressure
echo 400 > /proc/sys/vm/dirty_expire_centisecs
echo 6000 > /proc/sys/vm/dirty_writeback_centisecs
echo 0 > /proc/sys/vm/oom_dump_tasks
echo 0 > /proc/sys/vm/page-cluster
echo 0 > /proc/sys/vm/block_dump
echo 10 > /proc/sys/vm/stat_interval
echo 1 > /proc/sys/vm/compaction_proactiveness
echo 1 > /proc/sys/vm/watermark_boost_factor
echo 50 > /proc/sys/vm/watermark_scale_factor
echo 2 > /proc/sys/vm/drop_caches
echo 50 > /proc/sys/vm/swappiness

# Swappiness for memory control groups
for sw in /dev/memcg/*/memory.swappiness; do
    [ -f "$sw" ] && echo 50 > "$sw"
done

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

for path in /dev/stune/*; do
    base=$(basename "$path")
    
    if [[ "$base" == "top-app" || "$base" == "foreground" ]]; then
        echo 20 > "$path/schedtune.boost"
        echo 1 > "$path/schedtune.sched_boost_enabled"
    else
        echo 10 > "$path/schedtune.boost"
        echo 0 > "$path/schedtune.sched_boost_enabled"
    fi
    
    echo 0 > "$path/schedtune.prefer_idle"
    echo 0 > "$path/schedtune.colocate"
done


sleep 1
# Set balance
setprop sakuraai.mode balance
echo " •> Sakura Bloom activated at $(date "+%H:%M:%S")" >> $LOG

# Report
sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ 🌸 Sakura Bloom ] /g' "$BASEDIR/module.prop"
am start -a android.intent.action.MAIN -e toasttext "🌸 Sakura Bloom" -n bellavita.toast/.MainActivity

exit 0
