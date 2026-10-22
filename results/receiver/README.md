# Receiver outputs

Run `addpath(fullfile(pwd,'code')); runReceiverProject` from the repository root.
The runner regenerates these outputs in place.

| Folder or file | Meaning |
| --- | --- |
| `adaptive_smoke_20/` | Initial adaptive run, 20 frames per scenario |
| `calibration_QPSK/`, `calibration_16QAM/`, `calibration_64QAM/` | Separate-seed fixed-mode calibration, 100 frames per scenario |
| `fixed_QPSK/`, `fixed_16QAM/`, `fixed_64QAM/` | Fixed-mode comparison, 500 frames per scenario |
| `adaptive_500/` | Corrected final adaptive run, 500 frames per scenario |
| `calibrated_config.mat` | Configuration used for final runs, including selected thresholds |
| `receiver_validation_log.txt` | MATLAB validation diary |
| `archive_before_timing_fix/` | Superseded diagnostic export; do not use for final conclusions |

Each run folder contains `receiver_frames.csv` (per-frame data),
`receiver_summary.csv` (six-scenario metrics), `receiver_run.mat` (MATLAB data),
`receiver_performance.png` (BER/PER/goodput/latency),
`receiver_sinr_validation.png` (estimated versus diagnostic SINR), and
`receiver_example.png` (synchronization/channel/constellation example).
The bundle is written to `results/receiver_results.zip`.
