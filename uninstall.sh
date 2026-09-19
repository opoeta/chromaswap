#!/bin/sh
[ -f /opt/config/mod/.shell/0.sh ] && . /opt/config/mod/.shell/0.sh
[ -f /usr/data/zmod/zmod/.shell/0.sh ] && . /usr/data/zmod/zmod/.shell/0.sh
[ -n "$ZMOD_SH" ] && . "$ZMOD_SH"

NAME=chromaswap
SOURCE_DIR="${MOD_CONF}/mod_data/plugins/${NAME}"
TARGET_DIRS="/usr/data/zmod/klipper/klippy/extras ${KLIPPER_DIR}/klippy/extras"

for file in "$SOURCE_DIR"/*.py; do
    [ -e "$file" ] || continue
    for target in $TARGET_DIRS; do
        [ -L "$target/$(basename "$file")" ] && rm "$target/$(basename "$file")"
    done
done

sed -i "/plugins\/${NAME}\//d" "${MOD_CONF}/mod_data/plugins.cfg" 2>/dev/null

echo "chromaswap uninstalled"
echo "FIRMWARE_RESTART" >"${PRINTER_FIFO:-/tmp/printer}"
