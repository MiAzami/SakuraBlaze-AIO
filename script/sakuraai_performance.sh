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

# Find Mali GPU directory
mali_dir=$(ls -d /sys/devices/platform/soc/*mali* 2>/dev/null)

if [ -n "$mali_dir" ]; then
    echo "Mali directory found at: $mali_dir"

    # Set values directly if files exist
    if [ -f "$mali_dir/js_ctx_scheduling_mode" ]; then
        echo 0 > "$mali_dir/js_ctx_scheduling_mode" && echo "Successfully set $mali_dir/js_ctx_scheduling_mode to 1"
    else
        echo "$mali_dir/js_ctx_scheduling_mode not found"
    fi

    if [ -f "$mali_dir/js_scheduling_period" ]; then
        echo 20 > "$mali_dir/js_scheduling_period" && echo "Successfully set $mali_dir/js_scheduling_period to 20"
    else
        echo "$mali_dir/js_scheduling_period not found"
    fi

    if [ -f "$mali_dir/dvfs_period" ]; then
        echo 10 > "$mali_dir/dvfs_period" && echo "Successfully set $mali_dir/dvfs_period to 10"
    else
        echo "$mali_dir/dvfs_period not found"
    fi
fi

# Enable CPUs
for cpu in /sys/devices/system/cpu/cpu[0-7]; do
    echo 1 > "$cpu/online"
done

# Set CPU frequency governors to performance mode
for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    chmod 644 "$policy/scaling_governor"
    echo "performance" > "$policy/scaling_governor"
done

# Set device frequency governors to performance mode
for device in /sys/class/devfreq/*; do
    if [ -f "$device/governor" ]; then
        chmod 644 "$device/governor"
        echo "performance" > "$device/governor"
    fi
done

# GPU frequency settings
if [ -d /proc/gpufreq ]; then
    gpu_freq=$(grep -o 'freq = [0-9]*' /proc/gpufreq/gpufreq_opp_dump | sed 's/freq = //' | sort -nr | head -n 1)
    apply "$gpu_freq" /proc/gpufreq/gpufreq_opp_freq
elif [ -d /proc/gpufreqv2 ]; then
    apply 00 /proc/gpufreqv2/fix_target_opp_index
fi

# Additional GPU settings
echo "coarse_demand" > /sys/class/misc/mali0/device/power_policy

# Disable 
echo 0 0 > /proc/ppm/policy_status  # Disable PTPOD
echo 1 0 > /proc/ppm/policy_status  # Disable UT (Uplink Throttling)
echo 2 0 > /proc/ppm/policy_status  # Disable FORCE_LIMIT
echo 3 0 > /proc/ppm/policy_status  # Disable PWR_THRO
echo 4 0 > /proc/ppm/policy_status  # Disable THERMAL
echo 5 0 > /proc/ppm/policy_status  # Disable DLPT
echo 7 0 > /proc/ppm/policy_status  # Disable USER_LIMIT
echo 8 0 > /proc/ppm/policy_status  # Disable LCM_OFF (Display off throttling)

# Enable
echo 6 1 > /proc/ppm/policy_status  # Enable HARD_USER_LIMIT
echo 9 1 > /proc/ppm/policy_status  # Enable SYS_BOOST


# Set permissions to allow read/write on frequency scaling
chmod 644 /sys/devices/system/cpu/*/cpufreq/scaling_max_freq
chmod 644 /sys/devices/system/cpu/*/cpufreq/scaling_min_freq

# Manage frequency limits for CPU clusters (4:3:1 architecture)
cluster=0
for path in /sys/devices/system/cpu/cpufreq/policy*; do
    # Extract the first (minimum) frequency and the last (maximum) frequency
    min_freq=$(cut -d' ' -f1 "$path/scaling_available_frequencies")
    max_freq=$(awk '{print $NF}' "$path/scaling_available_frequencies")

    # Apply the minimum and maximum frequencies to the corresponding cluster's hard limits
    echo "$cluster $min_freq" > /proc/ppm/policy/hard_userlimit_min_cpu_freq
    echo "$cluster $max_freq" > /proc/ppm/policy/hard_userlimit_max_cpu_freq

    # Increment the cluster counter
    cluster=$((cluster + 1))
done

# Loop through all CPU cores (for 4:3:1 architecture, we have 8 cores in total)
for cpu in /sys/devices/system/cpu/cpu[0-7]; do
    # Check if the cpufreq directory exists for this CPU
    if [ -d "$cpu/cpufreq" ]; then
        # Get the available frequencies for this CPU
        available_freqs=$(cat "$cpu/cpufreq/scaling_available_frequencies" 2>/dev/null)

        # If available frequencies are found
        if [ -n "$available_freqs" ]; then
            # Set maximum frequency to the first frequency in the list
            first_freq=$(cut -d' ' -f1 "$cpu/cpufreq/scaling_available_frequencies")
            echo "$first_freq" > "$cpu/cpufreq/scaling_max_freq"

            # Set the minimum frequency to the first frequency
            echo "$first_freq" > "$cpu/cpufreq/scaling_min_freq"
        fi
    fi
done

# Reset permissions to read-only for scaling frequencies
chmod 444 /sys/devices/system/cpu/*/cpufreq/scaling_max_freq
chmod 444 /sys/devices/system/cpu/*/cpufreq/scaling_min_freq


# GPU frequency limit table
if [ -f "/proc/gpufreq/gpufreq_limit_table" ]; then
    for setting in ignore_batt_oc ignore_batt_percent ignore_batt_low ignore_thermal ignore_pbm; do
        echo "$setting 1" >> /proc/gpufreq/gpufreq_limit_table
    done
fi

# Disable Energy Aware Scheduling (EAS) and set various CPU freq settings
echo 0 > /sys/devices/system/cpu/eas/enable
echo 3 > /proc/cpufreq/cpufreq_power_mode
echo 1 > /proc/cpufreq/cpufreq_cci_mode
echo 1 > /proc/cpufreq/cpufreq_sched_disable
echo 0 > /proc/gpufreq/gpufreq_power_limited

# CPUSET configuration
for cs in /dev/cpuset
do
    echo 0-7 > "$cs/cpus"
    echo 0-6 > "$cs/background/cpus"
    echo 0-3 > "$cs/system-background/cpus"
    echo 0-7 > "$cs/foreground/cpus"
    echo 0-7 > "$cs/top-app/cpus"
    echo 0-5 > "$cs/restricted/cpus"
    echo 0-7 > "$cs/camera-daemon/cpus"
    echo 0 > "$cs/memory_pressure_enabled"
    echo 0 > "$cs/sched_load_balance"
    echo 0 > "$cs/foreground/sched_load_balance"
done

# Disallow power saving mode for display
for dlp in /proc/displowpower
do
    echo 1 > "$dlp/hrt_lp"
    echo 1 > "$dlp/idlevfp"
    echo 100 > "$dlp/idletime"
done

# Scheduler settings
echo 500000 > /proc/sys/kernel/sched_migration_cost_ns
echo 10 > /proc/sys/kernel/perf_cpu_time_max_percent
echo 10000000 > /proc/sys/kernel/sched_latency_ns
echo 1024 > /proc/sys/kernel/sched_util_clamp_max
echo 1024 > /proc/sys/kernel/sched_util_clamp_min
echo 2 > /proc/sys/kernel/sched_tunable_scaling
echo 1 > /proc/sys/kernel/sched_child_runs_first
echo 0 > /proc/sys/kernel/sched_energy_aware
echo 250000 > /proc/sys/kernel/sched_util_clamp_min_rt_default
echo 2000000 > /proc/sys/kernel/sched_deadline_period_max_us
echo 100 > /proc/sys/kernel/sched_deadline_period_min_us
echo 0 > /proc/sys/kernel/sched_schedstats
echo 3000000 > /proc/sys/kernel/sched_wakeup_granularity_ns
echo 1000000 > /proc/sys/kernel/sched_min_granularity_ns

# Block device settings
for device in /sys/block
do
    [ -d "$device/queue" ] || continue
    echo 0 > "$device/queue/add_random"
    echo 0 > "$device/queue/iostats"
    echo 2 > "$device/queue/nomerges"
    echo 2 > "$device/queue/rq_affinity"
    echo 128 > "$device/queue/nr_requests"
    echo 4096 > "$device/queue/read_ahead_kb"
    [ "$(cat "$device/queue/rotational")" -eq 0 ] && echo 0 > "$device/queue/rotational"
done

# Power level settings
for pl in /sys/devices/system/cpu/perf
do
    echo 1 > "$pl/gpu_pmu_enable"
    echo 1000000 > "$pl/gpu_pmu_period"
    echo 1 > "$pl/fuel_gauge_enable"
    echo 1 > "$pl/enable"
    echo 1 > "$pl/charger_enable"
done

# Virtual memory settings
echo 10 > /proc/sys/vm/dirty_background_ratio
echo 15 > /proc/sys/vm/dirty_ratio
echo 180 > /proc/sys/vm/vfs_cache_pressure
echo 3000 > /proc/sys/vm/dirty_expire_centisecs
echo 5000 > /proc/sys/vm/dirty_writeback_centisecs
echo 0 > /proc/sys/vm/oom_dump_tasks
echo 3 > /proc/sys/vm/page-cluster
echo 0 > /proc/sys/vm/block_dump
echo 10 > /proc/sys/vm/stat_interval
echo 0 > /proc/sys/vm/compaction_proactiveness
echo 1 > /proc/sys/vm/watermark_boost_factor
echo 30 > /proc/sys/vm/watermark_scale_factor
echo 3 > /proc/sys/vm/drop_caches
echo 30 > /proc/sys/vm/swappiness

# Memory control group swappiness
for sw in /dev/memcg
do
    echo 30 > "$sw/memory.swappiness"
done

for path in /dev/stune/*; do
    base=$(basename "$path")
    
    if [[ "$base" == "top-app" || "$base" == "foreground" ]]; then
        echo 40 > "$path/schedtune.boost"
        echo 1 > "$path/schedtune.sched_boost_enabled"
    else
        echo 10 > "$path/schedtune.boost"
        echo 0 > "$path/schedtune.sched_boost_enabled"
    fi
    
    echo 0 > "$path/schedtune.prefer_idle"
    echo 0 > "$path/schedtune.colocate"
done

am kill-all

# Set perf
setprop sakuraai.mode performance
echo " •> Gaming mode activated at $(date "+%H:%M:%S")" >> $LOG

# Report
sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ 🌸 Gaming Mode ] /g' "$BASEDIR/module.prop"
am start -a android.intent.action.MAIN -e toasttext "🌸 Gaming Mode" -n bellavita.toast/.MainActivity

exit 0
