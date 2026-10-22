# Question 20 project status - 22 October 2026

## What is implemented

- **A / Lokesh:** framed, seeded OFDM transmitter with QPSK/16-QAM/64-QAM, preamble, header, CRC, power scaling and spectrum/resource-map figures. `checkLokeshTx` and `runLokeshTx` pass in MATLAB R2026b.
- **B / Prisha:** six-case channel with log-distance path loss, fixed per-location shadowing, frame-varying four-tap fading, thermal noise and independent asynchronous OFDM interference. `checkChannelIntegration` and `runChannelValidation(500)` pass.
- **C / Abhinav:** timing detection, training/pilot channel estimation and equalization, header/payload recovery, CRC and six-case metrics. `checkReceiver` and the full `runReceiverProject` pass. The full run comprises a 20-frame smoke test, 100-frame-per-mode calibration, and 500-frame-per-case evaluations for each fixed modulation and adaptive modulation. Calibrated previous-frame SINR thresholds are 40/44 dB.
- **D / Soukaryo:** the analysis specification and an honest draft are available, but real RSSI readings/screenshots and the 10/15/20 dBm power comparison are absent. The D conclusion is therefore provisional.

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

1. Record ten real RSSI readings at each of near, middle and edge with one permitted 2.4 GHz AP and listed phone app. Save raw rows in `data/field_rssi.csv` and original screenshots in `figures/field/`. Record actual distance, obstacles, app, phone, AP channel and time. Compare measured **relative** RSSI drops with the simulated trend; do not invent readings or claim absolute calibration without AP power information.
2. Run a matched-seed candidate study at 10, 15 and 20 dBm for fixed QPSK/16-QAM/64-QAM and the adaptive rule. Apply the decision rule in `handoffs/DESIGN_FREEZE_AND_HANDOFFS.md`. If no tested option meets all low-load targets, state that and recommend a specific further change as unverified.
3. Replace every `[FILL]` in the handwriting draft with authentic group or measurement information. Check all figures and numbers against the final run after any config change. Have all four names/signatures on every handwritten page; scan into one PDF.
4. The handwritten FISAC-2 PDF is due **25 October 2026, 5:00 PM**. The FISAC-1 project PDF and experiment ZIP are due **1 November 2026, 5:00 PM**. Only the team lead uploads them. Include code, raw field data, plots, tables and reproducible commands in the final experiment ZIP.

## Git state

This status describes the tested `main` contents as of 22 October 2026. Keep this file updated if field data, model parameters, or the final power decision changes.
