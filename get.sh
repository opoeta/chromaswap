#!/bin/sh
# One-line installer:  curl -fsSL https://raw.githubusercontent.com/opoeta/chromaswap/main/get.sh | sh
# Pin a version:       ... | CHROMASWAP_REF=v0.1.0 sh
# Fetches the plugin into $MOD_CONF/mod_data/plugins/chromaswap (git clone when git exists, so
# it can later be updated with git pull), then runs install.sh.
REPO="${CHROMASWAP_REPO:-opoeta/chromaswap}"
REF="${CHROMASWAP_REF:-main}"
URL="${CHROMASWAP_URL:-https://github.com/$REPO}"    # CHROMASWAP_URL: tests / forks only

[ -f /opt/config/mod/.shell/0.sh ] && . /opt/config/mod/.shell/0.sh          # AD5M
[ -f /usr/data/zmod/zmod/.shell/0.sh ] && . /usr/data/zmod/zmod/.shell/0.sh  # AD5X
[ -n "$ZMOD_SH" ] && . "$ZMOD_SH"                                            # tests only

[ -n "$MOD_CONF" ] && [ -d "$MOD_CONF/mod_data/plugins" ] || {
    echo "chromaswap: MOD_CONF='$MOD_CONF' has no mod_data/plugins - is Z-Mod installed?"; exit 1; }
DEST="$MOD_CONF/mod_data/plugins/chromaswap"
TMP="$DEST.new"; rm -rf "$TMP"

if command -v git >/dev/null 2>&1; then
    git clone -q --depth 1 --branch "$REF" "$URL.git" "$TMP" 2>/dev/null || git clone -q --depth 1 --branch "$REF" "$URL" "$TMP" \
        || { echo "chromaswap: git clone of $URL ($REF) failed"; rm -rf "$TMP"; exit 1; }
else
    mkdir -p "$TMP" || exit 1
    tarball="$URL/archive/$REF.tar.gz"
    { if command -v curl >/dev/null 2>&1; then curl -fsSL --max-time 60 "$tarball"; else wget -qO- "$tarball"; fi; } \
        | tar xz -C "$TMP" --strip-components=1 \
        || { echo "chromaswap: download of $tarball failed"; rm -rf "$TMP"; exit 1; }
fi
[ -f "$TMP/install.sh" ] && [ -f "$TMP/chromaswap.cfg" ] || { echo "chromaswap: downloaded content looks wrong, aborting"; rm -rf "$TMP"; exit 1; }

rm -rf "$DEST" && mv "$TMP" "$DEST" && cd "$DEST" && exec sh ./install.sh
