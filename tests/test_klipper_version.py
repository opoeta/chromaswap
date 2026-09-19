import importlib.util, pathlib, sys
p = pathlib.Path(__file__).parent.parent / 'chromaswap_klipper.py'
spec = importlib.util.spec_from_file_location('ck', p); ck = importlib.util.module_from_spec(spec); spec.loader.exec_module(ck)

assert ck.parse_series('v0.12.0-45-gabc123') == 12
assert ck.parse_series('v0.13.0-5-g1234-dirty') == 13
assert ck.parse_series('0.12.0') == 12
assert ck.parse_series('') is None and ck.parse_series(None) is None
assert ck.parse_series('kalico-2025') is None and ck.parse_series('v1.0.0') is None
assert ck.pick_profile(12)[0::2] == (12, True)
assert ck.pick_profile(13)[0::2] == (13, True)
assert ck.pick_profile(11)[0::2] == (12, False)   # unknown -> default profile, known=False
assert ck.pick_profile(None)[0::2] == (12, False)
print('ok')
