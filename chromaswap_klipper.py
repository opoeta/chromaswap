# chromaswap: detects the Klipper series (0.12 -> 12, 0.13 -> 13) and applies the matching profile.
# Exposed to macros as printer.chromaswap_klipper.series / .version / .known.
import re

DEFAULT_SERIES = 12  # the series chromaswap is developed and tested against
# series -> {macro name: {variable: value}}, applied with SET_GCODE_VARIABLE on klippy:ready.
# Values are pasted into SET_GCODE_VARIABLE VALUE=..., so strings need Jinja quotes: "'text'".
# ponytail: empty until a real per-version difference is measured on the printer.
PROFILES = {12: {}, 13: {}}


def parse_series(software_version):
    """'v0.12.0-45-gabc' -> 12; anything unrecognised -> None."""
    m = re.match(r'\s*v?0\.(\d+)\.\d+', software_version or '')
    return int(m.group(1)) if m else None


def pick_profile(series):
    """Return (series actually used, profile, known). Unknown series fall back to DEFAULT_SERIES."""
    known = series in PROFILES
    used = series if known else DEFAULT_SERIES
    return used, PROFILES[used], known


class ChromaswapKlipper:
    def __init__(self, config):
        self.printer = config.get_printer()
        self.version = self.printer.get_start_args().get('software_version', '')
        self.series = parse_series(self.version)
        self.used, self.profile, self.known = pick_profile(self.series)
        self.printer.register_event_handler('klippy:ready', self._handle_ready)

    def _handle_ready(self):
        gcode = self.printer.lookup_object('gcode')
        if not self.known:
            gcode.respond_info(
                'chromaswap: Klipper "%s" is not a tested series (12 expected); using the %d profile.'
                % (self.version, self.used))
        for macro, variables in self.profile.items():
            for name, value in variables.items():
                gcode.run_script_from_command(
                    'SET_GCODE_VARIABLE MACRO=%s VARIABLE=%s VALUE=%s' % (macro, name, value))

    def get_status(self, eventtime):
        return {'version': self.version, 'series': self.series, 'profile_series': self.used, 'known': self.known}


def load_config(config):
    return ChromaswapKlipper(config)
