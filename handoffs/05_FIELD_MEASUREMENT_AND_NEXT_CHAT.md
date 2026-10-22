# Field RSSI measurement and next-chat handoff

## Project state at handoff (22 October 2026)

The repository is `wcc-proj`, branch `main`. The last published commit before this handoff is `e4de1c4`. Transmitter, six-case channel and receiver are implemented. MATLAB R2026b functional checks and the full 500-frame-per-case baseline run passed. The adaptive 15 dBm baseline meets the group's low-load PER <=5% and goodput >=5 Mbps targets at only **1 of 3** locations. See `CURRENT_STATUS.md`, `report/HANDWRITTEN_COPY_DRAFT.md`, `results/receiver/adaptive_500/receiver_summary.csv`, and `results/channel_validation_results.csv`. Real field RSSI measurements and the matched 10/15/20 dBm power study remain outstanding. Do not fill D with invented readings or call the 15 dBm setting final.

## App to use

On an **Android phone**, install [WiFi Analyzer (open-source) by VREM Software Development](https://play.google.com/store/apps/details?id=com.vrem.wifianalyzer). This is a current app whose name matches the assignment's listed **WiFi Analyzer** category. Its [user manual](https://github.com/VREMSoftwareDevelopment/WiFiAnalyzer/blob/main/USER_MANUAL.md) describes the access-point list, 2.4 GHz filter, time graph, and dBm signal values. If the phone is an iPhone or this app cannot scan, use another app from page 2 of the assignment that shows numeric 2.4 GHz RSSI in dBm; record the exact app and version. Do not substitute signal bars or a speed test for RSSI.

On Android, allow the app's needed scan permission and turn on Location services if prompted; the app listing says Android 9+ requires these to scan. The app may show repeated old values because Android throttles Wi-Fi scans. Wait for an actual refresh; extend the collection interval rather than counting an unchanged screen ten times. Android defines Wi-Fi RSSI as received signal strength in dBm ([API reference](https://developer.android.com/reference/android/net/wifi/WifiInfo#getRssi())). Values are usually negative; a value closer to zero is stronger.

## Before taking readings

1. Get permission to observe **one** 2.4 GHz access point, ideally the group's own router/hotspot or a permitted campus AP. Keep that AP and its transmit settings fixed during the survey. Avoid testing other people's traffic.
2. In WiFi Analyzer, select the **2.4 GHz** band. Identify the same physical AP in the access-point list. Use its BSSID (radio MAC) privately to distinguish it from other APs sharing an SSID; in the public CSV use a stable anonymized `ap_label`, such as `AP1`, and record the actual channel. Do not publish a full private SSID or BSSID in screenshots.
3. Use one phone and keep its orientation/height approximately the same. Choose three points matching the scenario labels: `near` (same room/clear), `middle` (corridor or one obstruction), `edge` (farther/more obstructions). Estimate the **actual** distances and write down walls/doors. Do not claim the measured points are exactly the simulation's 2, 8 and 20 m unless they really are.
4. Record phone model, app name/version, date, local time zone, AP label, band, channel and approximate distance. If the AP changes channel or your phone roams to a different radio, record that and repeat the affected point with one stable AP.

## At each location

1. Stand still, open the chosen AP's numeric signal display or time graph, and let the scan settle briefly.
2. Record **10 refreshed RSSI values in dBm**, approximately evenly spaced over about one minute. Record the local timestamp of each observation. If scan updates are slower, use a longer period and note it. Keep every reading, including outliers; do not average on the phone or copy the same stale reading repeatedly.
3. Take at least one screenshot showing the app, AP/channel and numeric dBm value at that location. A time-graph screenshot is useful as additional evidence. Save originals as `figures/field/near.png`, `middle.png`, `edge.png` (or `.jpg`). Crop/redact private network identifiers while keeping the app and readings legible. Preserve original uncropped screenshots privately if needed for audit.
4. Repeat at `middle` and `edge` with the same phone, AP and orientation. Note any doors opening, people moving or other condition changes in `notes`.

## Enter the raw data

Create `data/field_rssi.csv` using exactly the header in `data/field_rssi_TEMPLATE.csv`:

```csv
location,sample,approximate_distance_m,rssi_dBm,timestamp_local,app,phone_model,ap_label,band_ghz,channel,obstacles,notes
```

Enter **30 rows**, samples 1-10 for each of `near`, `middle`, `edge`. `rssi_dBm` is a signed number such as `-60` (the actual value you observed); do not include `dBm` in the numeric cell. Use an ISO-like local timestamp such as `2026-10-22 14:35:10 IST`. Keep raw rows unchanged. Use a separate analysis file or table for means and standard deviations. If an app export uses different columns, retain the original export as evidence and convert a copy into this schema.

## What the next chat should do

After the CSV and screenshots are in the repository, ask the next assistant to:

1. Check there are 10 authentic numeric readings per location and that the same AP/channel/phone were used; flag missing metadata or suspicious duplicate/stale samples for review.
2. Compute mean, sample standard deviation and near-relative RSSI change for each location. Compare only the **relative trend** with the simulated desired-power values near `-34.40`, middle `-62.74`, edge `-73.16` dBm. Explain uncertainty and mismatch without claiming absolute calibration of the unknown AP EIRP.
3. Run a matched-seed 10/15/20 dBm MATLAB comparison of fixed QPSK, 16-QAM, 64-QAM and the adaptive rule; use the decision rule in `handoffs/DESIGN_FREEZE_AND_HANDOFFS.md`. Preserve the raw field file and baseline results.
4. Replace the D-section `[FILL]` markers in `report/HANDWRITTEN_COPY_DRAFT.md`, update `CURRENT_STATUS.md`, and identify the exact field screenshots and resulting plot to attach to the handwritten pages.

Suggested first message in the next chat: "Read `CURRENT_STATUS.md`, `handoffs/05_FIELD_MEASUREMENT_AND_NEXT_CHAT.md`, and `report/HANDWRITTEN_COPY_DRAFT.md`. I have added the real field CSV and screenshots. Validate them, finish Section D, run the 10/15/20 dBm power comparison with matched seeds, update the status/draft, and report the final configuration honestly."
