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
LOG=/storage/emulated/0/SakuraAi/Powersaver.log

for cpu in /sys/devices/system/cpu/cpu[2-3]; do
    echo 0 > "$cpu/online"
done
for device in /sys/class/devfreq/*; do
    if [ -f "$device/governor" ]; then
        chmod 644 "$device/governor"
        echo "powersave" > "$device/governor"
    fi
done

# Set powersave
setprop sakuraai.mode powersaver
echo " •> Powersaver activated at $(date "+%H:%M:%S")" >> $LOG

# Report
sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[  💤 Powersaver Mode ] /g' "$BASEDIR/module.prop"
am start -a android.intent.action.MAIN -e toasttext "💤 Powersaver Mode " -n bellavita.toast/.MainActivity

exit 0
