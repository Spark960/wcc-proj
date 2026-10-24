# Question 20 project status - 24 October 2026

## Update: 24 October 2026

The A/B/C/D handwritten text is now finalized in `report/HANDWRITTEN_COPY_DRAFT.md` (the filename is historical). It includes the selected 20 dBm QPSK six-case outcome. `report/FINAL_ASSEMBLY_GUIDE.md` gives exact page, image, scanning, typed-PDF and ZIP steps; `report/FLOWCHARTS_TO_DRAW.md` gives both diagrams. `report/build_experiment_zip.py` prepares the final experiment ZIP after the separately authored project PDF exists. The remaining work requires the team's actual identity details, physical handwriting/signatures, page scans, final typed PDF and team-lead uploads.

MATLAB R2026b passed `checkLokeshTx`, `checkChannelIntegration`, and `checkReceiver`, then completed `runPowerStudy(500)`: 10, 15, and 20 dBm × fixed QPSK, 16-QAM, 64-QAM, and adaptive, over all six scenarios with 500 frames each (36,000 total attempts). The aggregate has 72 rows in `results/receiver/power_study/power_study_500.csv`; per-run CSVs, MAT files and figures are in `results/receiver/power_*_500/`. The rerun's 15 dBm adaptive failure counts and goodput match the earlier baseline in all six scenarios. Combined plots are `results/receiver/power_study/power_study_low_load_per.png` and `field_trend_preliminary.png` in the same folder.

No tested configuration meets the group's low-load target at all three locations. At 20 dBm fixed QPSK, near/middle/edge low-load failures are 0/500, 17/500, and 165/500, with goodput 16.000, 15.456, and 10.720 Mbps. It is the best tested fallback under the predeclared worst-location PER / worst-location goodput rule, tied with 20 dBm adaptive on those two metrics but passing the middle PER limit where adaptive has 27/500 failures (5.4%). Thus even the fallback reaches only 2/3 locations; do not call it a validated 3/3 design. The simulation config remains at the 15 dBm baseline; the 20 dBm choice is a **provisional tested fallback**, not a silent config change. A coding/interleaving change and new matched-seed run are required to test whether edge reliability can meet target.

The latest field dataset is **24 real timestamped AP-list export rows** for one 2.4 GHz channel-7 BSSID `d8:38:0d:1b:40:51`: 7 near, 11 middle and 6 far, in `data/field_rssi.csv`. The unchanged 115,582-byte user paste is in `data/raw/`, with extraction/audit in `code/extractFieldRssi.py` and `data/field_rssi_source_audit.md`. Descriptive mean RSSI is -68.71, -72.45 and -94.00 dBm. Near-relative drops are 3.74 and 25.29 dB, versus simulated 28.34 and 38.77 dB. Several consecutive exports repeat the same RSSI; all six far values equal -94 dBm, so the rows may include scan caching and cannot be treated as independent samples. The earlier BSSID `...40:c1` disappears in the far section and its three-point dataset is preserved separately, not mixed with the new one. The 19:34–19:38 time-graph screenshots in `figures/field/` are from a different session than the 20:15–20:20 exports. Synthetic readings are excluded. Physical distances, obstacles and phone model remain unknown. See `report/HANDWRITTEN_COPY_DRAFT.md` and `report/FINAL_ASSEMBLY_GUIDE.md`.

## What is implemented

- **A / Lokesh:** framed, seeded OFDM transmitter with QPSK/16-QAM/64-QAM, preamble, header, CRC, power scaling and spectrum/resource-map figures. `checkLokeshTx` and `runLokeshTx` pass in MATLAB R2026b.
- **B / Prisha:** six-case channel with log-distance path loss, fixed per-location shadowing, frame-varying four-tap fading, thermal noise and independent asynchronous OFDM interference. `checkChannelIntegration` and `runChannelValidation(500)` pass.
- **C / Abhinav:** timing detection, training/pilot channel estimation and equalization, header/payload recovery, CRC and six-case metrics. `checkReceiver` and the full `runReceiverProject` pass. The full run comprises a 20-frame smoke test, 100-frame-per-mode calibration, and 500-frame-per-case evaluations for each fixed modulation and adaptive modulation. Calibrated previous-frame SINR thresholds are 40/44 dB.
- **D / Soukaryo:** the 10/15/20 dBm power comparison is complete and Section D is updated. The latest field evidence has 24 real AP-list export rows for one BSSID across three locations. The broad near-to-far weakening is visible, but the middle field drop differs substantially from the model and repeated values may be cached.

## Reproduced baseline results

The 22 October local MATLAB R2026b run completed with exit code 0. It regenerated `results/channel_validation_results.csv`, `results/receiver/adaptive_500/receiver_summary.csv`, the associated plots and MAT files, the receiver diary, and `results/receiver_results.zip`. The result ZIP passed an integrity check and contains 50 files. The final adaptive CSV contains six rows, 500 attempts each (3000 total), with 1276 failed and 1724 delivered packets. Reproduced numeric CSVs agree with the prior seeded run.

| Scenario | Failed/500 | PER | Goodput Mbps | Low-load target |
| --- | ---: | ---: | ---: | --- |
| near, low | 1 | 0.2% | 31.872 | Pass |
| near, high | 38 | 7.6% | 25.741 | Stress case |
| middle, low | 50 | 10.0% | 14.400 | Fail PER |
| middle, high | 403 | 80.6% | 3.104 | Stress case |
| edge, low | 285 | 57.0% | 6.880 | Fail PER |
| edge, high | 499 | 99.8% | 0.032 | Stress case |

The predeclared low-load target is PER <=5% and goodput >=5 Mbps at all three locations. The current 15 dBm simulated baseline passes at **1/3** locations; it is not a completed engineering configuration. High-load interference substantially worsens PER. The results depend on assumed distances, wall losses, fixed shadow draws and an uncoded custom OFDM model; they are not Wi-Fi field performance measurements.

## Files to use

- Handwriting source and figure placement: `report/HANDWRITTEN_COPY_DRAFT.md`.
- Final receiver metrics: `results/receiver/adaptive_500/receiver_summary.csv` and `receiver_frames.csv` in the same folder.
- Channel budget and diagnostic SINR: `results/channel_validation_results.csv`.
- Run guide and output map: `code/README.md` and `results/receiver/README.md`.
- Previous flawed receiver export: `results/receiver/archive_before_timing_fix/`; never use it for final performance claims.

## Required work before submission

1. Use the 24 authentic AP1 rows in `data/field_rssi.csv` and preserve `data/raw/` as evidence. Report 7/11/6 export rows and label their averages descriptive because repeated RSSI may be cached; do not imply 24 independent radio scans or claim absolute calibration. The older graph screenshots are a separate session. If the team can still document actual distances, obstacles and phone model, add those truthful details before submission; otherwise state they are unknown.
2. The matched-seed 10/15/20 dBm study is complete. Since none of the tested options meets all low-load targets, test the proposed coding/interleaving change before claiming improved coverage. The current 20 dBm QPSK choice is only the best tested fallback under the existing model.
3. Replace every `[FILL]` in the handwriting draft with authentic group or measurement information. Check all figures and numbers against the final run after any config change. Have all four names/signatures on every handwritten page; scan into one PDF.
4. The handwritten FISAC-2 PDF is due **25 October 2026, 5:00 PM**. The FISAC-1 project PDF and experiment ZIP are due **1 November 2026, 5:00 PM**. Only the team lead uploads them. Include code, raw field data, plots, tables and reproducible commands in the final experiment ZIP.

## Git state

The baseline results came from the tested 22 October `main` contents. The 24 October power study, field screenshots and documentation are local working-tree changes; check Git status before packaging or publishing.
