#!/bin/sh
# chromaswap install: link the Klipper extra(s) and make sure the plugin cfg is included.
# Aborts (no include, no restart) if it cannot link at least one module, so Klipper never
# restarts into a config that references a missing module.
[ -f /opt/config/mod/.shell/0.sh ] && . /opt/config/mod/.shell/0.sh          # AD5M
[ -f /usr/data/zmod/zmod/.shell/0.sh ] && . /usr/data/zmod/zmod/.shell/0.sh  # AD5X
[ -n "$ZMOD_SH" ] && . "$ZMOD_SH"                                            # tests only

NAME=chromaswap
MODULES="chromaswap_klipper"     # keep in sync with uninstall.sh
SOURCE_DIR="${MOD_CONF}/mod_data/plugins/${NAME}"
TARGET_DIRS="/usr/data/zmod/klipper/klippy/extras ${KLIPPER_DIR}/klippy/extras"
PLUGINS_CFG="${MOD_CONF}/mod_data/plugins.cfg"

if [ -z "$MOD_CONF" ] || [ ! -f "$SOURCE_DIR/${NAME}.cfg" ]; then
    echo "chromaswap: MOD_CONF='$MOD_CONF' - plugin not found at $SOURCE_DIR, aborting"; exit 1
fi

linked=0
for mod in $MODULES; do
    src="$SOURCE_DIR/$mod.py"
    [ -f "$src" ] || { echo "chromaswap: missing $src, aborting"; exit 1; }
    for target in $TARGET_DIRS; do
        [ -d "$target" ] || continue
        dst="$target/$mod.py"
        if [ -e "$dst" ] && [ ! -L "$dst" ]; then
            echo "chromaswap: $dst exists and is not a symlink, leaving it alone"; continue
        fi
        ln -sf "$src" "$dst" && linked=$((linked+1)) && echo "chromaswap: linked $dst"
    done
done
[ "$linked" -gt 0 ] || { echo "chromaswap: no klippy/extras dir found, aborting"; exit 1; }

# ENABLE_PLUGIN normally adds this include; only add it if it is missing.
if [ -f "$PLUGINS_CFG" ] && ! grep -q "plugins/${NAME}/" "$PLUGINS_CFG"; then
    echo "[include plugins/${NAME}/${NAME}.cfg]" >> "$PLUGINS_CFG"
    echo "chromaswap: added '[include plugins/${NAME}/${NAME}.cfg]' to $PLUGINS_CFG"
fi

echo "chromaswap installed"
echo "FIRMWARE_RESTART" >"${PRINTER_FIFO:-/tmp/printer}"
