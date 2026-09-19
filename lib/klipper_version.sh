#!/bin/sh
# Prints the Klipper series of the running host (0.12.x -> 12, 0.13.x -> 13), or nothing if unknown.
# Asks Moonraker, which reports the same software_version string Klipper itself uses.
klipper_series() {
    curl -s --max-time 5 http://localhost:7125/printer/info \
        | sed -n 's/.*"software_version"[[:space:]]*:[[:space:]]*"v\{0,1\}0\.\([0-9]*\)\..*/\1/p'
}
