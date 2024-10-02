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

echo "0" > /sys/devices/system/cpu/cpu2/online
echo "0" > /sys/devices/system/cpu/cpu3/online
echo "powersave" > /sys/class/devfreq/mtk-dvfsrc-devfreq/governor
echo "powersave" > /sys/class/devfreq/13000000.mali/governor

# Set powersave
setprop sakuraai.mode powersaver
echo " •> Powersaver activated at $(date "+%H:%M:%S")" >> $LOG

# Report
sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[  💤 Powersaver Mode ] /g' "$BASEDIR/module.prop"
am start -a android.intent.action.MAIN -e toasttext "💤 Powersaver Mode " -n bellavita.toast/.MainActivity

exit 0