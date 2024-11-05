# Set permissions

ui_print " "
ui_print " Module info: "
ui_print " • Name            : SakuraBlazeAI"
ui_print " • Codename        : ICELAVA"
ui_print " • Status          : Public Release "
ui_print " • Owner           : MiAzami "
ui_print " • Build Date      : 04-06-2024"
ui_print " • Support Varians : Universal Mediatek"
ui_print " "
sleep 1
ui_print " Thanks To:"
ui_print " — MiAzami //Mod"
ui_print " — Riprog //Support"
ui_print " — Rem01Gaming //Support"
ui_print " — Ramabondap //Support"
ui_print " — Azazil //Support"
ui_print " — All Tester"
ui_print " — All Dev Re;Surrection"
sleep 0.2
ui_print " "
ui_print " Preparing Settings..."
sleep 1
ui_print " [ Normal if u gout delayed after boot ] "
sleep 0.5
ui_print " [ Wait for under 5 mintues ]"
sleep 1
ui_print " "
# Set permissions
ui_print " ⚙️ Settings permissions"
sleep 0.5
ui_print " Apply Tweaks & Settings: ✅"
ui_print " "
ui_print " Preparing Settings..."
ui_print " ⚙️ Setting permissions"
sleep 1

on_install() {
  ui_print "- Extracting module files"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
}

# Run addons
if [ "$(ls -A $MODPATH/addon/*/install.sh 2>/dev/null)" ]; then
  ui_print "- Running Addons"
  for i in $MODPATH/addon/*/install.sh; do
    ui_print "  Running $(echo $i | sed -r "s|$MODPATH/addon/(.*)/install.sh|\1|")..."
    . $i
  done
fi

ui_print "" 
ui_print "  Volume Key Selector to select options:"
ui_print "  1) ZRAM"
ui_print "  2) Disable HW Overlays"
ui_print "  3) Enable FPSGO"
ui_print "  4) Advanced FPSGO"
ui_print ""
ui_print "  Button Function:"
ui_print "  • Volume + (Next)"
ui_print "  • Volume - (Select)"
ui_print ""
sleep 2

# If there's no existing module, clean up any other busybox modules
if ! [ -d "/data/adb/modules/${MODID}" ]; then
    find /data/adb/modules -maxdepth 1 -name -type d | while read -r another_bb; do
        wleowleo="$(echo "$another_bb" | grep -i 'busybox')"
        if [ -n "$wleowleo" ] && [ -d "$wleowleo" ] && [ -f "$wleowleo/module.prop" ]; then
            touch "$wleowleo"/remove
        fi
    done            
fi

# If the module is already installed, remove the installed flag
if [ -d "/data/adb/modules/${MODID}" ] && [ -f "/data/adb/modules/${MODID}/installed" ]; then
    rm -f /data/adb/modules/${MODID}/installed
fi

# Zram
ui_print "  ➡️ ZRAM size..."
ui_print "    1. Default(using default zram from device)"
ui_print "    2. Disable"
ui_print "    3. 1 GB"
ui_print "    4. 2 GB"
ui_print "    5. 3 GB"
ui_print "    6. 4 GB"
ui_print "    7. 5 GB"
ui_print "    8. 6 GB"
ui_print "    9. 7 GB"
ui_print "    10. 8 GB"
ui_print ""
ui_print "    😶‍🌫️ IF YOU NOT UNDERSTAND, SKIP INSTALL"
ui_print ""
ui_print "    Select:"
A=1
while true; do
    ui_print "    $A"
    if $VKSEL; then
        A=$((A + 1))
    else
        break
    fi
    if [ $A -gt 10 ]; then
        A=1
    fi
done
ui_print "    Selected: $A"
case $A in
    1 ) TEXT1="Default";;
    2 ) TEXT1="Disable"; sed -i '/#change_zram/s/.*/disable_zram/' $MODPATH/service.sh;;
    3 ) TEXT1="1 GB"; sed -i '/ZRAMSIZE=0/s/.*/ZRAMSIZE=1G/' $MODPATH/service.sh; sed -i '/#change_zram/s/.*/change_zram/' $MODPATH/service.sh;;
    4 ) TEXT1="2 GB"; sed -i '/ZRAMSIZE=0/s/.*/ZRAMSIZE=2G/' $MODPATH/service.sh; sed -i '/#change_zram/s/.*/change_zram/' $MODPATH/service.sh;;
    5 ) TEXT1="3 GB"; sed -i '/ZRAMSIZE=0/s/.*/ZRAMSIZE=3G/' $MODPATH/service.sh; sed -i '/#change_zram/s/.*/change_zram/' $MODPATH/service.sh;;
    6 ) TEXT1="4 GB"; sed -i '/ZRAMSIZE=0/s/.*/ZRAMSIZE=4G/' $MODPATH/service.sh; sed -i '/#change_zram/s/.*/change_zram/' $MODPATH/service.sh;;
    7 ) TEXT1="5 GB"; sed -i '/ZRAMSIZE=0/s/.*/ZRAMSIZE=5G/' $MODPATH/service.sh; sed -i '/#change_zram/s/.*/change_zram/' $MODPATH/service.sh;;
    8 ) TEXT1="6 GB"; sed -i '/ZRAMSIZE=0/s/.*/ZRAMSIZE=6G/' $MODPATH/service.sh; sed -i '/#change_zram/s/.*/change_zram/' $MODPATH/service.sh;;
    9 ) TEXT1="7 GB"; sed -i '/ZRAMSIZE=0/s/.*/ZRAMSIZE=7G/' $MODPATH/service.sh; sed -i '/#change_zram/s/.*/change_zram/' $MODPATH/service.sh;;
    10 ) TEXT1="8 GB"; sed -i '/ZRAMSIZE=0/s/.*/ZRAMSIZE=8G/' $MODPATH/service.sh; sed -i '/#change_zram/s/.*/change_zram/' $MODPATH/service.sh;;
esac
ui_print "    $TEXT1"
ui_print ""

# DISABLE HW OVERLAYS
ui_print "  ⚙️ Disable HW Overlays..."
ui_print "    1. Yes"
ui_print "    2. No"
ui_print "    CAUTION!! WILL DRAIN YOUR BATTERY, WILL USED YOUR GPU"
ui_print ""
ui_print "    😶‍🌫️ IF YOU NOT UNDERSTAND, SKIP INSTALL"
ui_print ""
ui_print "    Select:"
B=1
while true; do
    ui_print "    $B"
    if $VKSEL; then
        B=$((B + 1))
    else
        break
    fi
    if [ $B -gt 2 ]; then
        B=1
    fi
done
ui_print "    Selected: $B"
case $B in
    1 ) TEXT2="Yes"; sed -i '/#doverlay/s/.*/doverlay/' $MODPATH/service.sh;;
    2 ) TEXT2="No";;
esac
ui_print "    $TEXT2"
ui_print ""

# FPSGO
ui_print "  ⚡️ Enable FPSGO Settings..."
ui_print "    1. Yes"
ui_print "    2. No / Skip Install"
ui_print ""
ui_print "    😶‍🌫️ IF YOU NOT UNDERSTAND, SKIP INSTALL"
ui_print ""
ui_print "    Select:"
C=1
while true; do
    ui_print "    $C"
    if $VKSEL; then
        C=$((C + 1))
    else
        break
    fi
    if [ $C -gt 2 ]; then
        C=1
    fi
done
ui_print "    Selected: $C"
case $C in
    1 ) TEXT3="Yes"; sed -i '/#fpsgo2/s/.*/fpsgo2/' $MODPATH/service.sh;;
    2 ) TEXT3="No";;
esac
ui_print "    $TEXT3"
ui_print ""

# FPSGO
ui_print "  ⚡️ Enable Advanced FPSGO Settings..."
ui_print "    1. Yes"
ui_print "    2. No / Skip Install"
ui_print ""
ui_print "    😶‍🌫️ IF YOU NOT UNDERSTAND, SKIP INSTALL"
ui_print ""
ui_print "    Select:"
D=1
while true; do
    ui_print "    $D"
    if $VKSEL; then
        D=$((D + 1))
    else
        break
    fi
    if [ $D -gt 2 ]; then
        D=1
    fi
done
ui_print "    Selected: $D"
case $D in
    1 ) TEXT4="Yes"; sed -i '/#fpsgo/s/.*/fpsgo/' $MODPATH/service.sh;;
    2 ) TEXT4="No";;
esac
ui_print "    $TEXT4"
ui_print ""

sleep 1
ui_print "  Your settings:"
ui_print "  1) ZRAM Size	        : $TEXT1"
ui_print "  2) Disable HW Overlays    : $TEXT2"
ui_print "  3) Enable FPSGO           : $TEXT3"
ui_print "  4) Enable Advanced FPSGO  : $TEXT4"
ui_print " "
ui_print "- Apply options"
ui_print " "

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive $MODPATH/script 0 0 0755 0755
set_perm_recursive $MODPATH/vendor 0 0 0755 0755
set_perm_recursive $MODPATH/system 0 0 0755 0755

# Install toast app
ui_print " 📲 Install Toast app"
pm install $MODPATH/Toast.apk
ui_print " "

# Check rewrite directory
if [ ! -e /storage/emulated/0/SakuraAi ]; then
  mkdir /storage/emulated/0/SakuraAi
fi

# Check applist file
if [ ! -e /storage/emulated/0/SakuraAi/applist_perf.txt ]; then
  cp -f $MODPATH/script/applist_perf.txt /storage/emulated/0/SakuraAi
fi

nohup am start -a android.intent.action.VIEW -d https://t.me/mtkvestg99 >/dev/null 2>&1 &
