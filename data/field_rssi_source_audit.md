# Audit of the 24 October 2026 evening AP exports

The original user-pasted text is preserved unchanged at `raw/wifi_ap_exports_2026-10-24_near_middle_edge.txt`. Two dotted separator lines split it into **near**, **middle**, and **far** sections, in that order. The sections contain 7, 11, and 10 distinct export timestamps respectively. Some rows for unrelated APs are truncated in the pasted text; the selected AP rows are complete.

The previously used BSSID `d8:38:0d:1b:40:c1` appears near and middle but **not** far in this newer session. For the final three-location comparison we selected `d8:38:0d:1b:40:51` (`iBus@Block-10`), which is present in all three sections on one stable 2.4 GHz channel, channel 7 (2442 MHz), and has 7 near, 11 middle, and 6 far rows. `code/extractFieldRssi.py` filters this exact BSSID and writes the unaltered observed RSSI numbers and timestamps to `data/field_rssi.csv`.

| Location | Time span (IST) | Exported RSSI sequence (dBm) | Rows | Distinct RSSI values |
| --- | --- | --- | ---: | ---: |
| Near | 20:15:50–20:17:35 | -67, -67, -67, -67, -67, -73, -73 | 7 | 2 |
| Middle | 20:17:42–20:19:20 | -75, -71, -71, -71, -71, -71, -71, -74, -74, -74, -74 | 11 | 3 |
| Far/edge | 20:19:52–20:20:25 | -94, -94, -94, -94, -94, -94 | 6 | 1 |

The exported rows have distinct timestamps, but repeated values—especially six identical far values—may reflect Android Wi-Fi scan caching/throttling. Treat their means as **descriptive averages of exported rows**, not independent-sample estimates with known uncertainty. The AP is absent from the final four far-section timestamps. Physical distances, obstacles, phone model, AP EIRP and received-signal calibration were not supplied. The earlier 19:34/19:36/19:38 screenshots are from a separate session and are not the source of these 20:15–20:20 numeric rows.
