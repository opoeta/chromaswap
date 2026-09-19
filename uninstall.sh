#!/bin/sh
[ -f /opt/config/mod/.shell/0.sh ] && . /opt/config/mod/.shell/0.sh
[ -f /usr/data/zmod/zmod/.shell/0.sh ] && . /usr/data/zmod/zmod/.shell/0.sh
[ -n "$ZMOD_SH" ] && . "$ZMOD_SH"

NAME=chromaswap
MODULES="chromaswap_klipper"     # keep in sync with install.sh
TARGET_DIRS="/usr/data/zmod/klipper/klippy/extras ${KLIPPER_DIR}/klippy/extras"

for mod in $MODULES; do
    for target in $TARGET_DIRS; do
        [ -L "$target/$mod.py" ] && rm "$target/$mod.py" && echo "chromaswap: removed $target/$mod.py"
    done
done

[ -n "$MOD_CONF" ] && sed -i "/plugins\/${NAME}\//d" "${MOD_CONF}/mod_data/plugins.cfg" 2>/dev/null

echo "chromaswap uninstalled"
echo "FIRMWARE_RESTART" >"${PRINTER_FIFO:-/tmp/printer}"
