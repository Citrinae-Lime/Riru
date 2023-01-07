#!/system/bin/sh
MODDIR=${0%/*}
TMPPROP="$(magisk --path)/riru.prop"
MIRRORPROP="$(magisk --path)/.magisk/modules/riru-core/module.prop"

ORIG_NB="$(getprop ro.dalvik.vm.native.bridge)"
BAK_NB="libnb_bak.so"

for bit in "64" ""; do
    if [ -f "/system/lib$bit/libnb.so" ]; then
        rm -rf "$MODDIR/system/lib$bit/libnb.so"
        # link libriruloader to libnb
        ln -s ./libriruloader.so "$MODDIR/system/lib$bit/libnb.so"

        touch "$MODDIR/system/lib$bit/$BAK_NB"
        if [ ! -z "$ORIG_NB" ] && [ "$ORIG_NB" != "0" ]; then
            mount --bind "$(magisk --path)/.magisk/mirror/system/lib$bit/libnb.so" "$(magisk --path)/.magisk/modules/riru-core/system/lib$bit/$BAK_NB"
        else
            mount --bind "$(magisk --path)/.magisk/mirror/system/lib$bit/$ORIG_NB" "$(magisk --path)/.magisk/modules/riru-core/system/lib$bit/$BAK_NB"
        fi
        # tell rirud the original nb is now $BAK_NB
        ORIG_NB="$BAK_NB"
    fi
done


sh -Cc "cat '$MODDIR/module.prop' > '$TMPPROP'"
if [ $? -ne 0 ]; then
  exit
fi
mount --bind "$TMPPROP" "$MIRRORPROP"
if [ "$ZYGISK_ENABLE" = "1" ]; then
    sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ ⛔ Riru is not loaded because of Zygisk. ] /g' "$MIRRORPROP"
    exit
fi
sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ ⛔ app_process fails to run. ] /g' "$MIRRORPROP"
cd "$MODDIR" || exit
flock "module.prop"
mount --bind "$TMPPROP" "$MODDIR/module.prop"
unshare -m sh -c "/system/bin/app_process -Djava.class.path=rirud.apk /system/bin --nice-name=rirud riru.Daemon $(magisk -V) $(magisk --path) $ORIG_NB &"
umount "$MODDIR/module.prop"
