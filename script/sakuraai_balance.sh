#!/system/bin/sh

# Sync to data in the rare case a device crashes
sync

# Functions
read_file() {
  if [[ -f $1 ]]; then
    # Check if file is not readable and attempt to make it readable
    [[ -r $1 ]] || chmod +r "$1"
    # Display the file content
    cat "$1"
  else
    echo "File '$1' not found"
  fi
}

# Path
BASEDIR=/data/adb/modules/SakuraAi
LOG=/storage/emulated/0/SakuraAi/Balance.log

# Better Battery Efficient
chmod 0644 /sys/module/workqueue/parameters/power_efficient
echo "Y" > /sys/module/workqueue/parameters/power_efficient
chmod 0644 /sys/module/workqueue/parameters/disable_numa
echo "Y" > /sys/module/workqueue/parameters/disable_numa

echo 1 > /proc/ppm/enabled
echo 0 1 > /proc/ppm/policy_status
echo 1 0 > /proc/ppm/policy_status
echo 2 1 > /proc/ppm/policy_status
echo 3 1 > /proc/ppm/policy_status
echo 4 1 > /proc/ppm/policy_status
echo 5 1 > /proc/ppm/policy_status
echo 6 0 > /proc/ppm/policy_status
echo 7 0 > /proc/ppm/policy_status
echo 8 1 > /proc/ppm/policy_status
echo 9 0 > /proc/ppm/policy_status

cmd power set-adaptive-power-saver-enabled true
cmd power set-fixed-performance-mode-enabled false

for cpu in /sys/devices/system/cpu/cpu[0-7]; do
    if [ -f "$cpu/online" ]; then
        echo 1 > "$cpu/online"
    fi
done

# Set CPU frequency governors to performance mode
for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    chmod 644 "$policy/scaling_governor"
    echo "schedutil" > "$policy/scaling_governor"
done

# Set device frequency governors to performance mode
for device in /sys/class/devfreq/*; do
    if [ -f "$device/governor" ]; then
        chmod 644 "$device/governor"
        echo "simple_ondemand" > "$device/governor"
    fi
done

if [ -d /proc/gpufreq ]; then
    echo 0 /proc/gpufreq/gpufreq_opp_freq
elif [ -d /proc/gpufreqv2 ]; then
    echo 0 /proc/gpufreqv2/fix_target_opp_index
fi

# Set permissions and manage cluster frequencies
chmod 644 /sys/devices/system/cpu/*/cpufreq/scaling_max_freq
chmod 644 /sys/devices/system/cpu/*/cpufreq/scaling_min_freq
cluster=0
for path in /sys/devices/system/cpu/cpufreq/policy*; do
    max_freq=$(cat "$path/scaling_available_frequencies" | cut -d' ' -f1)
    min_freq=$(cat "$path/scaling_available_frequencies" | awk '{print $NF}')
    echo "$cluster $max_freq" > /proc/ppm/policy/hard_userlimit_min_cpu_freq
    echo "$cluster $min_freq" > /proc/ppm/policy/hard_userlimit_max_cpu_freq
    cluster=$(($cluster + 1))
done

# Set individual CPU frequencies
for cpu in /sys/devices/system/cpu/cpu[0-7]; do
    [ ! -d "$cpu/cpufreq" ] && continue
    freqs=$(cat "$cpu/cpufreq/scaling_available_frequencies" 2>/dev/null) || continue
    max_freq=$(echo "$freqs" | cut -d' ' -f1)
    min_freq=$(echo "$freqs" | awk '{print $NF}')
    
    if echo "$max_freq" > "$cpu/cpufreq/scaling_max_freq"; then
        echo "CPU $cpu: max freq set to $max_freq"
    else
        echo "CPU $cpu: failed to set max freq"
    fi
    
    if echo "$min_freq" > "$cpu/cpufreq/scaling_min_freq"; then
        echo "CPU $cpu: min freq set to $min_freq"
    else
        echo "CPU $cpu: failed to set min freq"
    fi
done

chmod 444 /sys/devices/system/cpu/*/cpufreq/scaling_max_freq
chmod 444 /sys/devices/system/cpu/*/cpufreq/scaling_min_freq

# Additional GPU settings
echo "coarse_demand" > /sys/class/misc/mali0/device/power_policy

if [ -f "/proc/gpufreq/gpufreq_power_limited" ]; then
	apply "ignore_batt_oc 0" /proc/gpufreq/gpufreq_power_limited
	apply "ignore_batt_percent 0" /proc/gpufreq/gpufreq_power_limited
	apply "ignore_low_batt 0" /proc/gpufreq/gpufreq_power_limited
	apply "ignore_thermal_protect 0" /proc/gpufreq/gpufreq_power_limited
	apply "ignore_pbm_limited 0" /proc/gpufreq/gpufreq_power_limited
fi

# Disable Energy Aware Scheduling (EAS) and set various CPU freq settings
echo 1 > /sys/devices/system/cpu/eas/enable
echo 0 > /proc/cpufreq/cpufreq_power_mode
echo 0 > /proc/cpufreq/cpufreq_cci_mode
echo 1 > /proc/cpufreq/cpufreq_sched_disable
echo 1 > /sys/kernel/eara_thermal/enable
echo stop 0 > /proc/pbm/pbm_stop

# CPUSET configuration
for cs in /dev/cpuset
do
    echo 0-7 > "$cs/cpus"
    echo 0-5 > "$cs/background/cpus"
    echo 0-4 > "$cs/system-background/cpus"
    echo 0-7 > "$cs/foreground/cpus"
    echo 0-7 > "$cs/top-app/cpus"
    echo 0-5 > "$cs/restricted/cpus"
    echo 0-7 > "$cs/camera-daemon/cpus"
done

# Disallow power saving mode for display
for dlp in /proc/displowpower
do
    echo 1 > "$dlp/hrt_lp"
    echo 1 > "$dlp/idlevfp"
    echo 100 > "$dlp/idletime"
done

# Scheduler settings
echo 25 > /proc/sys/kernel/perf_cpu_time_max_percent
echo 1 > /proc/sys/kernel/sched_child_runs_first
echo 1 > /proc/sys/kernel/sched_energy_aware
echo 1 > /proc/sys/kernel/sched_schedstats

# Block device settings
for device in /sys/block/*; do
    if [ -d "$device/queue" ]; then
        echo 64 > "$device/queue/nr_requests"
        echo 128 > "$device/queue/read_ahead_kb"
    fi
done

# Power level settings
for pl in /sys/devices/system/cpu/perf
do
    echo 0 > "$pl/gpu_pmu_enable"
    echo 0 > "$pl/fuel_gauge_enable"
    echo 0 > "$pl/enable"
    echo 1 > "$pl/charger_enable"
done

# Virtual memory settings
echo 120 > /proc/sys/vm/vfs_cache_pressure
echo 0 > /proc/sys/vm/compaction_proactiveness
echo 80 > /proc/sys/vm/swappiness

# DCM
echo set 0xf8007 1 > /sys/dcm/dcm_state

# Set balance
setprop sakuraai.mode balance
echo " •> Sakura Bloom activated at $(date "+%H:%M:%S")" >> $LOG

# Report
sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ 🌸 Sakura Bloom ] /g' "$BASEDIR/module.prop"
am start -a android.intent.action.MAIN -e toasttext "🌸 Sakura Bloom" -n bellavita.toast/.MainActivity

exit 0
