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

# Try each downloader in turn; a tool that exists but is broken (e.g. curl without libcurl) is skipped.
fetched=0
if command -v git >/dev/null 2>&1; then
    git clone -q --depth 1 --branch "$REF" "$URL.git" "$TMP" 2>/dev/null         || git clone -q --depth 1 --branch "$REF" "$URL" "$TMP" 2>/dev/null && fetched=1
    [ "$fetched" = 1 ] || { echo "chromaswap: git clone failed, trying tarball"; rm -rf "$TMP"; }
fi
if [ "$fetched" = 0 ]; then
    tarball="$URL/archive/$REF.tar.gz"
    for dl in "curl -fsSL --max-time 60" "wget -qO-"; do
        set -- $dl; command -v "$1" >/dev/null 2>&1 || continue
        mkdir -p "$TMP" && $dl "$tarball" 2>/dev/null | tar xz -C "$TMP" --strip-components=1 2>/dev/null             && [ -f "$TMP/install.sh" ] && { fetched=1; break; }
        echo "chromaswap: $1 could not fetch $tarball"; rm -rf "$TMP"
    done
fi
[ "$fetched" = 1 ] || { echo "chromaswap: could not download $URL ($REF) with git, curl or wget."
    echo "Copy the release tarball to the printer by hand instead (see README, 'manual')."; exit 1; }
[ -f "$TMP/install.sh" ] && [ -f "$TMP/chromaswap.cfg" ] || { echo "chromaswap: downloaded content looks wrong, aborting"; rm -rf "$TMP"; exit 1; }

rm -rf "$DEST" && mv "$TMP" "$DEST" && cd "$DEST" && exec sh ./install.sh
