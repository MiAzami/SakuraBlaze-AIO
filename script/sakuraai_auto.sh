#!/system/bin/sh

sleep 1

# Paths
BASEDIR=/data/adb/modules/SakuraAi
INT=/storage/emulated/0
RWD=$INT/SakuraAi
LOG=$RWD/SakuraAi.log
MSC=$BASEDIR/script
BAL=$MSC/sakuraai_balance.sh
PERF=$MSC/sakuraai_performance.sh
SAV=$MSC/sakuraai_powersaver.sh

# Ensure the rewrite directory exists
if [ ! -d "$RWD" ]; then
  mkdir -p "$RWD"
fi

# Initialize log
echo " " > "$LOG"
echo " Device info: " >> "$LOG"
echo " • Brand           : $(getprop ro.product.system.brand) " >> "$LOG"
echo " • Device          : $(getprop ro.product.system.model) " >> "$LOG"
echo " • Processor       : $(getprop ro.product.board) " >> "$LOG"
echo " • Android Version : $(getprop ro.system.build.version.release)" >> "$LOG"
echo " • SDK Version     : $(getprop ro.build.version.sdk) " >> "$LOG"
echo " • Architecture    : $(getprop ro.product.cpu.abi) " >> "$LOG"
echo " • Kernel Version  : $(uname -r)" >> "$LOG"
echo " " >> "$LOG"
echo " Profile Mode:" >> "$LOG"

# Check applist file
if [ ! -e "$RWD/applist_perf.txt" ]; then
  cp -f "$MSC/applist_perf.txt" "$RWD"
fi

# Begin AI
sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ 🌱 Sakura will grow ] /g' "$BASEDIR/module.prop"
am start -a android.intent.action.MAIN -e toasttext "🌱 Sakura will grow." -n bellavita.toast/.MainActivity

# Set initial AI mode
setprop sakuraai.mode notset

# Initialize screen status for powersaver
prev_screen_status=""

# Start AI loop
while true; do
    sleep 10

    # Build app filter list
    app_list_filter="grep -o -e applist.app.add"
    while IFS= read -r applist || [[ -n "$applist" ]]; do
        filter=$(echo "$applist" | awk '!/ /')
        if [[ -n "$filter" ]]; then
            app_list_filter+=" -e $filter"
        fi
    done < "$RWD/applist_perf.txt"

    # Check if an app from the applist is active
    window=$(dumpsys window | grep package | $app_list_filter | tail -1)

    # Get the current mode once for efficiency
    current_mode=$(getprop sakuraai.mode)
    
    if [[ -n "$window" ]]; then
        package=$(echo "$window" | awk '{print $NF}')
        cmd device_config put game_overlay "$package" mode=2,downscaleFactor=0.7,fps=120,loadingBoost=999999999

        # Activate performance mode if needed
        if [[ "$current_mode" != "performance" ]]; then
            echo "Switching to Performance mode" >> "$LOG"  # Log this action
            sh "$PERF"
        fi
        sleep 5
    else
        # Activate balance mode if no window is active
        if [[ "$current_mode" != "balance" ]]; then
            echo "Switching to Balance mode" >> "$LOG"  # Log this action
            sh "$BAL"
        fi
        sleep 2
    fi

    # Check for screen status for power saver mode
    screen_status=$(dumpsys window | grep "mScreenOn" | grep false)
    if [[ "$screen_status" != "$prev_screen_status" ]]; then
        prev_screen_status="$screen_status"
        if [[ -n "$screen_status" ]]; then
            # Activate power saver mode if needed
            if [[ "$current_mode" != "powersaver" ]]; then
                echo "Switching to Power Saver mode" >> "$LOG"  # Log this action
                sh "$SAV"
            fi
            sleep 1
        fi
    fi
done
