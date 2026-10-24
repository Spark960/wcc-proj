"""Extract one consistently observed AP from the three user-provided exports."""

from __future__ import annotations

import csv
from datetime import datetime
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "data" / "raw" / "wifi_ap_exports_2026-10-24_near_middle_edge.txt"
OUTPUT = ROOT / "data" / "field_rssi.csv"
BSSID = "d8:38:0d:1b:40:51"
LOCATIONS = ("near", "middle", "edge")
FIELDS = (
    "location", "sample", "approximate_distance_m", "rssi_dBm",
    "timestamp_local", "app", "phone_model", "ap_label", "band_ghz",
    "channel", "obstacles", "notes",
)

sections = re.split(r"(?m)^\.{10,}\s*$", SOURCE.read_text(encoding="utf-8-sig"))
if len(sections) != 3:
    raise ValueError(f"Expected near/middle/far sections, found {len(sections)}")

records: list[dict[str, str | int]] = []
for location, section in zip(LOCATIONS, sections):
    selected = []
    for line in section.splitlines():
        parts = line.split("|")
        if len(parts) < 5 or parts[2].lower() != BSSID:
            continue
        if not re.fullmatch(r"-\d+dBm", parts[3]):
            raise ValueError(f"Invalid RSSI for {BSSID}: {line}")
        if parts[4] != "7" or parts[1] != "iBus@Block-10":
            raise ValueError(f"AP identity or channel changed: {line}")
        timestamp = datetime.strptime(parts[0], "%Y/%m/%d-%H:%M:%S")
        selected.append((timestamp, int(parts[3][:-3])))
    if not selected or len({timestamp for timestamp, _ in selected}) != len(selected):
        raise ValueError(f"Missing or duplicate timestamp for {location}")
    selected.sort()
    for sample, (timestamp, rssi) in enumerate(selected, start=1):
        records.append({
            "location": location,
            "sample": sample,
            "approximate_distance_m": "",
            "rssi_dBm": rssi,
            "timestamp_local": timestamp.strftime("%Y-%m-%d %H:%M:%S IST"),
            "app": "WiFi Analyzer",
            "phone_model": "",
            "ap_label": "AP1",
            "band_ghz": "2.4",
            "channel": "7",
            "obstacles": "",
            "notes": f"Original AP-list export; BSSID {BSSID}; repeated RSSI may reflect scan caching",
        })

with OUTPUT.open("w", encoding="utf-8", newline="") as stream:
    writer = csv.DictWriter(stream, fieldnames=FIELDS, lineterminator="\n")
    writer.writeheader()
    writer.writerows(records)
print(f"Wrote {len(records)} real export rows to {OUTPUT}")
for location in LOCATIONS:
    values = [int(r["rssi_dBm"]) for r in records if r["location"] == location]
    print(location, len(values), values)
