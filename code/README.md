# Lokesh's transmitter implementation

Open the cloned repository as MATLAB's Current Folder, then run in MATLAB R2026b or a compatible recent release:

```matlab
addpath(fullfile(pwd,'code'))
checkLokeshTx
runLokeshTx
```

The commands use the repository's current folder, so they work after cloning to a different computer. If MATLAB's Current Folder is elsewhere, first navigate to the cloned repository root in MATLAB.

`checkLokeshTx` checks the CRC-16 known vector (`123456789` → `29B1`), deterministic waveform generation, configured average transmit power and a zero-impairment OFDM loopback for all three modulation modes. `runLokeshTx` prints the rate/EIRP table and exports `../lokesh/figures/tx_resource_mapping.png` and `../lokesh/figures/tx_spectrum.png`.

## API for the group

```matlab
cfg = getConfig();
mode = selectTxMode(previousFrameSinrDb,cfg); % NaN for first frame
[txWaveform, txMeta] = transmitFrame(frameId,mode,cfg);
```

`txWaveform` is a complex column vector with mean squared magnitude equal to configured transmit power in watts, using a nominal 1-ohm complex-baseband convention. The antenna gain and feeder loss are **link-budget values**, not extra scaling of these samples. `txMeta` contains payload truth for offline BER comparison, header/CRC/padding data, carrier mapping and timing. Do not feed original payload bits or perfect channel information to the operational receiver.

The frame has two identical known preamble OFDM symbols, one QPSK header OFDM symbol and variable-length payload OFDM symbols. All OFDM symbols use 64 FFT bins and 16 CP samples. The 52 occupied bins are `-26:-1` and `1:26`, with pilots at `[-21 -7 7 21]` and 48 remaining data bins. The header contains marker `A7`, 16-bit frame ID, 2-bit mode, 16-bit payload length, CRC-8/ATM and zero padding. The payload uses CRC-16/CCITT-FALSE. Bit fields are MSB first. QAM is Gray coded and normalized to unit average constellation power. The complete frame is normalized once, then scaled to the configured transmit power.

`getConfig.m` currently sets 20 MHz sample rate/channel bandwidth, 15 dBm transmit power, 2 dBi Tx antenna gain and 0 dB feeder loss. Change `bandwidthHz` there; the sample rate follows it. Thus EIRP is 17 dBm. The uncoded continuous-symbol rates are 24, 48 and 72 Mbps for QPSK, 16-QAM and 64-QAM. For the 96-byte frames including preamble/header/CRC but assuming zero errors, the corresponding payload airtime rates are 16, 24 and 32 Mbps. None of these is measured goodput; failed frames and retransmissions are not included.

The SINR thresholds `[12 23]` dB are **provisional design assumptions**. Abhinav and Soukaryo should tune and justify them from PER results before calling the final configuration validated. `selectTxMode` uses only a **previous-frame** SINR report and defaults to QPSK on the first frame. The actual measured Wi-Fi RSSI dataset is still needed from Soukaryo; no field measurement is fabricated in this transmitter.

`getConfig.m` contains the agreed baseline assumptions for the channel, six scenarios, trial counts and evaluation targets. They are specified in `handoffs/DESIGN_FREEZE_AND_HANDOFFS.md` at the repository root. The transmitter, channel and receiver are implemented; field measurements and the final engineering decision remain outstanding.

## Integration notes

- `applyChannel` accepts the transmit waveform, configuration and scenario, and returns the received waveform with a separate diagnostic truth structure. `receiveFrame` uses only the received waveform and configuration.
- `receiveFrame` synchronizes with the preamble, estimates and equalizes the channel, decodes the header and payload, and checks CRC. `txIdealLoopback.m` remains a transmitter-only functional check.
- The exact use of 20 MHz, Tx power and RF channel in the real Wi-Fi measurement must be documented. The simulated transmitter is a generic OFDM link, not a claim that the phone or access point implements this exact waveform.

## Channel implementation and validation

`channelScenarios(cfg)` draws shadowing once per location using seed
`cfg.channelSeed + 10000 + locationIndex`. Its `shadowingDb` field is shared
by both loads and remains fixed when the frame seed changes. Custom scenarios
must supply this field. Change `cfg.channelSeed` for a different reproducible run.

Frame seeds start at `cfg.channelSeed + 100000*locationIndex`; the validation
runner adds `frameIndex - 1`. Low/high loads share fading and noise realizations
for matched comparisons. The default 500-frame runs fit within these ranges.

`channelOfdmInterference` uses a separate stream at `frameSeed + 1000000`,
independent random QPSK data, configured OFDM carriers/pilots and cyclic prefix.
It crops continuous traffic at a random offset of 1–79 samples for the default
80-sample symbol, then normalizes the retained samples to the specified
receiver-input power. Load represents interference power, not MAC scheduling.
This is a custom OFDM waveform, not standards-compliant WLAN. `-Inf` disables it.

Run from the repository root:

```matlab
addpath(fullfile(pwd,'code'))
checkLokeshTx
checkChannelIntegration
runChannelValidation(20)
% After checking the smoke results:
% runChannelValidation(500)
```

The checks cover repeatability, fixed shadowing with varying fading, matched
load realizations, interference power, cyclic prefix and null subcarriers.
`results/channel_validation_results.csv` and the three channel PNGs were
replaced with the user's MATLAB Online export from `runChannelValidation(500)`.
The imported table contains six scenarios with 500 frames each, identical
shadowing for the two loads at each location, and lower SINR under high load.
The CSV and PNG files were inspected locally; no MATLAB console/test log was
included in the export, so successful execution of the separate check scripts
has not been independently verified. These remain channel diagnostics, not
receiver BER/PER results. The waveform PNG has a minor overlap between its
lower title and scientific-notation axis label; adjust layout before report use.

## Part C receiver

`receiveFrame(rxWaveform,cfg)` performs timing, training-based channel estimation,
pilot gain correction, header validation, mode-aware demapping and payload CRC.
It receives no `txMeta` or true channel parameters. `rxDemap` shares the exact
constellation labeling with `txQamMap`. `checkReceiver` covers clean recovery,
unknown prefixes/gain, multipath, AWGN and damaged/truncated packets.

From this repository root in MATLAB:

```matlab
addpath(fullfile(pwd,'code'))
runReceiverProject
```

This runs functional checks, a 20-frame-per-case smoke run, 100-frame-per-case
fixed-mode calibration with separate seeds, and final 500-frame-per-case runs
for three fixed modes and the adaptive policy. It saves per-frame CSVs, summary
CSVs, MAT configuration/data and plots in `results/receiver/<run>/`, records a
console diary in `results/receiver/receiver_validation_log.txt`, and packages
`results/receiver_results.zip`. Calibration changes only
the run-local configuration; the selected configuration is saved with results.
Final adaptive results are under `results/receiver/adaptive_500/`. The 20-frame
smoke output is under `results/receiver/adaptive_smoke_20/`. The extra fixed-mode
runs support assessing adaptation rather than assuming it helps. If any check
fails, the runner stops and retains the diary for diagnosis.

Status: `runReceiverProject` completed locally in MATLAB R2026b on 22 October 2026.
The fresh diary, CSVs, MAT files and plots are under `results/receiver`; the ZIP
passed an integrity check. Selected thresholds are
40/44 dB. Only near-low meets both low-load reliability/goodput targets (1/3
locations); see `abhinav/PART_C_WRITEUP.md` for actual results and limitations.
The earlier export is archived under `results/receiver/archive_before_timing_fix`.

## Matched power study (24 October 2026)

From the repository root in MATLAB R2026b, run `addpath(fullfile(pwd,'code')); runPowerStudy(500); plotPowerStudy`. This checks the transmitter, channel and receiver, then evaluates 10/15/20 dBm with fixed QPSK, 16-QAM, 64-QAM and the calibrated 40/44 dB adaptive rule over six scenarios. The completed result and interpretation are in `results/receiver/power_study/README.md` and `power_study_500.csv` there. The 15 dBm baseline configuration in `getConfig.m` is retained for reproducibility; the 20 dBm fixed-QPSK result is a tested fallback, not a validated 3/3 design.
