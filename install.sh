#!/bin/sh
# chromaswap install: link the Klipper extra(s) and make sure the plugin cfg is included.
[ -f /opt/config/mod/.shell/0.sh ] && . /opt/config/mod/.shell/0.sh          # AD5M
[ -f /usr/data/zmod/zmod/.shell/0.sh ] && . /usr/data/zmod/zmod/.shell/0.sh  # AD5X
[ -n "$ZMOD_SH" ] && . "$ZMOD_SH"                                            # tests only

NAME=chromaswap
SOURCE_DIR="${MOD_CONF}/mod_data/plugins/${NAME}"
TARGET_DIRS="/usr/data/zmod/klipper/klippy/extras ${KLIPPER_DIR}/klippy/extras"
PLUGINS_CFG="${MOD_CONF}/mod_data/plugins.cfg"

for file in "$SOURCE_DIR"/*.py; do
    [ -e "$file" ] || continue
    for target in $TARGET_DIRS; do
        [ -d "$target" ] || continue
        ln -sf "$file" "$target/$(basename "$file")"
    done
done

# ENABLE_PLUGIN normally adds this include; only add it if it is missing.
if [ -f "$PLUGINS_CFG" ] && ! grep -q "plugins/${NAME}/" "$PLUGINS_CFG"; then
    echo "[include plugins/${NAME}/${NAME}.cfg]" >> "$PLUGINS_CFG"
fi

echo "chromaswap installed"
echo "FIRMWARE_RESTART" >"${PRINTER_FIFO:-/tmp/printer}"
