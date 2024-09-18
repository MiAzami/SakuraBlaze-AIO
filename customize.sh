# Set permissions

ui_print " "
ui_print " Module info: "
ui_print " • Name            : SakuraBlazeAI"
ui_print " • Codename        : Helio GORE—99"
ui_print " • Version         : V1.0.1750 X"
ui_print " • Status          : Public Release "
ui_print " • Owner           : MiAzami "
ui_print " • Build Date      : 04-06-2024"
ui_print " • Support Varians : Ultimate/Ultra"
ui_print " "
ui_print " Device info:"
ui_print " • Brand           : $(getprop ro.product.system.brand) "
ui_print " • Device          : $(getprop ro.product.system.model) "
ui_print " • Processor       : $(getprop ro.product.board) "
ui_print " • Android Version : $(getprop ro.system.build.version.release) "
ui_print " • SDK Version     : $(getprop ro.build.version.sdk) "
ui_print " • Architecture    : $(getprop ro.product.cpu.abi) "
ui_print " • Kernel Version  : $(uname -r) "
ui_print " "
ui_print " Thanks To:"
sleep 0.2
ui_print " — MiAzami //Mod"
ui_print " — Riprog //Support"
ui_print " — Rem01Gaming //Support"
ui_print " — Fastbooteraselk //EncBusybox"
ui_print " — Azazil //Codes"
ui_print " — All Tester"
ui_print " — All Dev Re;Surrection"
sleep 0.2
ui_print " "

sleep 1
ui_print " ================================================"
ui_print "                  ‼️ 𝙒𝘼𝙍𝙉𝙄𝙉𝙂 ‼️"
ui_print " "
ui_print " 𝘿𝙤𝙣𝙩 𝙐𝙨𝙚, 𝘼𝙥𝙥𝙡𝙮 𝘼𝙣𝙮 :"
ui_print " — 𝘛𝘸𝘦𝘢𝘬𝘴 / 𝘔𝘰𝘥 / 𝘖𝘱𝘵𝘪𝘮𝘪𝘻𝘢𝘵𝘪𝘰𝘯 𝘗𝘦𝘳𝘧𝘰𝘳𝘮𝘢𝘯𝘤𝘦"
ui_print " "
ui_print " [ 𝘖𝘯𝘭𝘺 𝘢𝘱𝘱𝘳𝘰𝘷𝘦𝘥 𝘮𝘰𝘥𝘪𝘧𝘪𝘤𝘢𝘵𝘪𝘰𝘯𝘴 𝘧𝘳𝘰𝘮 𝘵𝘳𝘶𝘴𝘵𝘦𝘥 𝘥𝘦𝘷𝘦𝘭𝘰𝘱𝘦𝘳𝘴"
ui_print " 𝘴𝘩𝘰𝘶𝘭𝘥 𝘣𝘦 𝘶𝘴𝘦𝘥 𝘵𝘰 𝘦𝘯𝘴𝘶𝘳𝘦 𝘤𝘰𝘯𝘵𝘪𝘯𝘶𝘦𝘥 𝘯𝘰𝘳𝘮𝘢𝘭 𝘧𝘶𝘯𝘤𝘵𝘪𝘰𝘯𝘪𝘯𝘨"
ui_print " 𝘢𝘯𝘥 𝘱𝘳𝘦𝘷𝘦𝘯𝘵 𝘱𝘰𝘵𝘦𝘯𝘵𝘪𝘢𝘭 𝘪𝘴𝘴𝘶𝘦𝘴. ]"
ui_print " "
ui_print "   𝘼𝙡𝙡𝙤𝙬 𝙏𝙤𝙖𝙨𝙩 𝙖𝙥𝙥𝙨 𝙞𝙛 𝙩𝙝𝙖𝙩 𝙙𝙚𝙩𝙚𝙘𝙩𝙚𝙙 𝙬𝙞𝙩𝙝 𝙋𝙡𝙖𝙮 𝙎𝙚𝙘𝙪𝙧𝙚"
ui_print " ================================================"
sleep 1
ui_print " "
ui_print " Preparing Settings..."
sleep 1
ui_print " [ Normal if u gout delayed after boot ] "
sleep 0.5
ui_print " [ Wait for under 5 mintues ]"
sleep 2
ui_print " "
# Set permissions
ui_print " ⚙️ Settings permissions"
sleep 0.5
ui_print " Apply Tweaks & Settings: ✅"
ui_print " "
ui_print " Preparing Settings..."
ui_print " ⚙️ Setting permissions"
sleep 1

# Run addons
if [ "$(ls -A $MODPATH/addon/*/install.sh 2>/dev/null)" ]; then
  
  for i in $MODPATH/addon/*/install.sh; do
    ui_print "  Running $(echo $i | sed -r "s|$MODPATH/addon/(.*)/install.sh|\1|")..."
    . $i
  done
fi

ui_print "" 
ui_print "  Volume Key Selector to select options:"
ui_print "  1) ZRAM"
ui_print "  2) GMS Doze"
ui_print ""
ui_print "  Button Function:"
ui_print "  • Volume + (Next)"
ui_print "  • Volume - (Select)"
ui_print ""
sleep 3

# Zram
ui_print "  ➡️ ZRAM size..."
ui_print "    1. Default(using default zram from device)"
ui_print "    2. Disable"
ui_print "    3. 1024MB"
ui_print "    4. 1536MB"
ui_print "    5. 2048MB"
ui_print "    6. 2560MB"
ui_print "    7. 3072MB"
ui_print "    8. 4096MB"
ui_print "    9. 5120MB"
ui_print "    10. 6144MB"
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
    3 ) TEXT1="1024MB"; sed -i '/ZRAMSIZE=0/s/.*/ZRAMSIZE=1025M/' $MODPATH/service.sh; sed -i '/#change_zram/s/.*/change_zram/' $MODPATH/service.sh;;
    4 ) TEXT1="1536MB"; sed -i '/ZRAMSIZE=0/s/.*/ZRAMSIZE=1537M/' $MODPATH/service.sh; sed -i '/#change_zram/s/.*/change_zram/' $MODPATH/service.sh;;
    5 ) TEXT1="2048MB"; sed -i '/ZRAMSIZE=0/s/.*/ZRAMSIZE=2049M/' $MODPATH/service.sh; sed -i '/#change_zram/s/.*/change_zram/' $MODPATH/service.sh;;
    6 ) TEXT1="2560MB"; sed -i '/ZRAMSIZE=0/s/.*/ZRAMSIZE=2561M/' $MODPATH/service.sh; sed -i '/#change_zram/s/.*/change_zram/' $MODPATH/service.sh;;
    7 ) TEXT1="3072MB"; sed -i '/ZRAMSIZE=0/s/.*/ZRAMSIZE=3073M/' $MODPATH/service.sh; sed -i '/#change_zram/s/.*/change_zram/' $MODPATH/service.sh;;
    8 ) TEXT1="4096MB"; sed -i '/ZRAMSIZE=0/s/.*/ZRAMSIZE=4097M/' $MODPATH/service.sh; sed -i '/#change_zram/s/.*/change_zram/' $MODPATH/service.sh;;
    9 ) TEXT1="5120MB"; sed -i '/ZRAMSIZE=0/s/.*/ZRAMSIZE=5121M/' $MODPATH/service.sh; sed -i '/#change_zram/s/.*/change_zram/' $MODPATH/service.sh;;
    10 ) TEXT1="6144MB"; sed -i '/ZRAMSIZE=0/s/.*/ZRAMSIZE=6145M/' $MODPATH/service.sh; sed -i '/#change_zram/s/.*/change_zram/' $MODPATH/service.sh;;
esac
ui_print "    $TEXT1"
ui_print ""

# GMS doze
ui_print "  🍃 GMS Doze..."
ui_print "    1. Enable"
ui_print "    2. Disable"
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
    1 ) TEXT2="Enable"; sed -i '/#gms_doze_patch/s/.*/doze_disable/' $MODPATH/post-fs-data.sh;;
    2 ) TEXT2="Disable"; sed -i '/#gms_doze_enable/s/.*/doze_enable/' $MODPATH/post-fs-data.sh;;
esac
ui_print "    $TEXT2"
ui_print ""

ui_print "  Your settings:"
ui_print "  1) ZRAM Size : $TEXT1"
ui_print "  2) GMS Doze  : $TEXT2"
ui_print " "
ui_print "  Apply Options"
ui_print " "
ui_print " 📦 Installing Busybox..."
sleep 5
# Define external variables
BPATH="$TMPDIR/system/xbin"
a="$MODPATH/system/xbin"
MODVER="$(grep_prop version ${TMPDIR}/module.prop)"

deploy() {

	unzip -qo "$ZIPFILE" 'system/*' -d $TMPDIR

	# Init
	set_perm "$BPATH/busybox*" 0 0 777

	# Detect Architecture

	case "$ARCH" in
	"arm64")
		mv -f $BPATH/busybox-arm64 $a/busybox
		
		;;
	esac
}

if ! [ -d "/data/adb/modules/${MODID}" ]; then
    find /data/adb/modules -maxdepth 1 -name -type d | while read -r another_bb; do
        wleowleo="$(echo "$another_bb" | grep -i 'busybox')"
        if [ -n "$wleowleo" ] && [ -d "$wleowleo" ] && [ -f "$wleowleo/module.prop" ]; then
            touch "$wleowleo"/remove
        fi
    done            
fi

if [ -d "/data/adb/modules/${MODID}" ] && [ -f "/data/adb/modules/${MODID}/installed" ]; then
	rm -f /data/adb/modules/${MODID}/installed
fi

# Extract Binary
deploy

# Print Busybox Version
BB_VER="$($a/busybox | head -n1 | cut -f1 -d'(')"

# Install into /system/bin, if exists.
if [ ! -e /system/xbin ]; then
	mkdir -p $MODPATH/system/bin
	mv -f $a/busybox $MODPATH/system/bin/busybox
	rm -Rf $a
	
fi

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
