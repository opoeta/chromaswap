# chromaswap

Z-Mod plugin for the Flashforge AD5X: slicer-controlled purge and low waste (bambufy + lessWaste)
with QuickSwap's fast color change. Work in progress — see `docs/superpowers/specs/`.

Based on: bambufy (function3d), lessWaste (Hrybmo), QuickSwap (ninjamida, MIT), Z-Mod (ghzserg).

## Current contents (test build)

Only the Klipper-version detector and a test macro, so the install path can be validated first:

- `chromaswap_klipper.py` — Klipper extra: detects the series (0.12 -> 12, 0.13 -> 13), picks a profile.
- `chromaswap.cfg` — loads the extra and defines `CHROMASWAP_INFO`.
- `install.sh` / `uninstall.sh` — link the extra into Klipper, add the include, restart Klipper.
- `lib/klipper_version.sh` — `klipper_series` shell function (asks Moonraker).

## Test on the printer

1. Build the package on the PC: `sh package.sh` -> `dist/chromaswap.tar.gz`.
2. Copy it to the printer and unpack into the plugins folder (`/opt/config/mod_data/plugins/`
   as seen inside the Z-Mod chroot; on the AD5X host that is
   `/usr/data/.mod/.zmod/opt/config/mod_data/plugins/`):
   ```sh
   scp dist/chromaswap.tar.gz root@<printer-ip>:/tmp/
   ssh root@<printer-ip>
   tar xzf /tmp/chromaswap.tar.gz -C /usr/data/.mod/.zmod/opt/config/mod_data/plugins/
   sh /usr/data/.mod/.zmod/opt/config/mod_data/plugins/chromaswap/install.sh
   ```
3. Klipper restarts. In the console run `CHROMASWAP_INFO`. Expected:
   `chromaswap: Klipper v0.12.x-... (series 12), profile 12, known True`.
4. Remove with `sh .../chromaswap/uninstall.sh`.

`ENABLE_PLUGIN name=chromaswap` will not work yet: Z-Mod downloads plugins from its own list,
and this one is not in it.

## Checked vs not checked

- Checked (Linux, fake tree): install/uninstall create and remove the symlinks, `plugins.cfg`
  gets exactly one include, install is idempotent; the parser unit test passes.
- **Not checked on a printer:** where `MOD_CONF`/`KLIPPER_DIR` point on your Z-Mod version, the
  chroot path above, the include line format in `plugins.cfg`, and that Moonraker answers on
  `localhost:7125`. If `CHROMASWAP_INFO` is unknown after the restart, send me the install output
  and the last lines of `klippy.log`.
